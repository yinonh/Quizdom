import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/bots.dart';
import 'package:trivia/core/global_providers/app_lifecycle_provider.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/enums/selected_emoji.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/data/models/shuffled_data.dart';
import 'package:trivia/data/models/trivia_achievements.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/providers/current_trivia_achievements_provider.dart';
import 'package:trivia/data/providers/trivia_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_bot_manager.dart';

part 'duel_quiz_screen_manager.freezed.dart';
part 'duel_quiz_screen_manager.g.dart';

@freezed
class DuelQuizState with _$DuelQuizState {
  const factory DuelQuizState({
    required List<Question> questions,
    required double timeLeft,
    required int questionIndex,
    required List<String> shuffledOptions,
    required int correctAnswerIndex,
    required String categoryName,
    @GameStageConverter() required GameStage gameStage,
    required Map<String, int> userScores,
    required List<String> users,
    TriviaUser? opponent,
    TriviaUser? currentUser,
    int? selectedAnswerIndex,
    String? roomId,
    @Default({}) Map<String, Map<int, int>> userAnswers,
    @Default(false) bool isHost,
    @Default(false) bool isOpponentBot,
    @Default(false) bool hasUserPaidCoins,
    @Default({}) Map<String, Map<String, dynamic>> userEmojis,
  }) = _DuelQuizState;

  factory DuelQuizState.fromJson(Map<String, dynamic> json) =>
      _$DuelQuizStateFromJson(json);
}

@riverpod
class DuelQuizScreenManager extends _$DuelQuizScreenManager {
  Timer? _timer;
  Timer? _lastSeenTimer;
  Timer? _checkPresenceTimer;
  StreamSubscription? _roomSubscription;
  String? _currentUserId;
  bool _isUpdatingTimestamp = false;
  bool _streamsActive = false;

  final BotManager _botManager = BotManager();

  String? getCurrentUserId() => _currentUserId;

  @override
  Future<DuelQuizState> build(String roomId) async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final triviaNotifier = ref.read(triviaProvider.notifier);
    final room = await TriviaRoomDataSource.getRoomById(roomId);
    final response = await triviaNotifier.getDuelTriviaQuestions(room);

    final opponentID =
        room?.users[0] == _currentUserId ? room?.users[1] : room?.users[0];

    final isOpponentBot = opponentID == AppConstant.botUserId;

    TriviaUser? opponent;
    if (isOpponentBot) {
      opponent = BotService.currentBot?.user;
    } else {
      opponent = await UserDataSource.getUserById(opponentID);
    }

    final currentUser = ref.read(authProvider).currentUser;

    if (room == null || room.roomId == null) {
      throw Exception("Room not initialized correctly");
    }

    _setupAppLifecycleListener(room.roomId!);
    _activateStreams(room.roomId!, room.currentStage, room.users);
    final initialShuffledData = _getShuffledOptions(response![0]);

    ref.onDispose(() {
      _deactivateStreams();
    });

    return DuelQuizState(
      questions: response,
      timeLeft: room.questionDuration.toDouble(),
      questionIndex: room.currentQuestionIndex,
      shuffledOptions: initialShuffledData.options,
      correctAnswerIndex: initialShuffledData.correctIndex,
      categoryName: room.categoryId.toString(),
      gameStage: room.currentStage,
      userScores: room.userScores ?? {},
      users: room.users,
      opponent: opponent,
      currentUser: currentUser,
      roomId: room.roomId,
      isHost: _currentUserId == room.hostUserId,
      isOpponentBot: isOpponentBot,
      userEmojis: room.userEmojis ?? {},
    );
  }

  void _activateStreams(String roomId, GameStage stage, List<String> users) {
    if (_streamsActive) return;
    _streamsActive = true;
    logger.i("Activating all streams and timers");
    _setupRoomSubscription(roomId);
    _startLastSeenUpdates(roomId, stage);
    _startPresenceChecking(roomId, users);
    if (_currentUserId != null) {
      TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
    }
  }

  void _setupRoomSubscription(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription =
        TriviaRoomDataSource.getRoomStream(roomId).listen((updatedRoom) {
      if (updatedRoom == null) return;

      state.whenData((quizState) {
        if (quizState.gameStage == GameStage.created &&
            updatedRoom.currentStage != GameStage.created) {
          _lastSeenTimer?.cancel();
          _lastSeenTimer = Timer.periodic(
            const Duration(seconds: 3),
            (_) {
              if (_currentUserId != null) {
                TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
              }
            },
          );
        }

        double calculatedTimeLeft = updatedRoom.questionDuration.toDouble();
        if (updatedRoom.currentStage == GameStage.active) {
          if (updatedRoom.currentQuestionStartTime != null) {
            final now = DateTime.now();
            final elapsedSeconds =
                now.difference(updatedRoom.currentQuestionStartTime!).inSeconds;
            calculatedTimeLeft =
                (updatedRoom.questionDuration - elapsedSeconds).toDouble();
            if (calculatedTimeLeft < 0) calculatedTimeLeft = 0;
          } else {
            if (quizState.isHost &&
                !_isUpdatingTimestamp &&
                updatedRoom.currentStage == GameStage.active) {
              _isUpdatingTimestamp = true;
              TriviaRoomDataSource.updateQuestionStartTime(roomId).then((_) {
                _isUpdatingTimestamp = false;
              }).catchError((error) {
                _isUpdatingTimestamp = false;
              });
            }
          }
        }

        final roomDoc = updatedRoom.toJson();
        final userAnswers = TriviaRoomDataSource.parseUserAnswers(roomDoc);

        ShuffledData? shuffledData;
        if (updatedRoom.currentQuestionIndex != quizState.questionIndex) {
          if (updatedRoom.currentQuestionIndex < quizState.questions.length) {
            shuffledData = _getShuffledOptions(
                quizState.questions[updatedRoom.currentQuestionIndex]);
          }
        }

        int? selectedAnswerIndex = quizState.selectedAnswerIndex;
        if (_currentUserId != null &&
            userAnswers.containsKey(_currentUserId) &&
            userAnswers[_currentUserId]!
                .containsKey(updatedRoom.currentQuestionIndex)) {
          selectedAnswerIndex =
              userAnswers[_currentUserId]![updatedRoom.currentQuestionIndex];
        } else if (updatedRoom.currentQuestionIndex !=
            quizState.questionIndex) {
          selectedAnswerIndex = null;
        }

        state = AsyncValue.data(
          quizState.copyWith(
            questionIndex: updatedRoom.currentQuestionIndex,
            gameStage: updatedRoom.currentStage,
            userScores: updatedRoom.userScores ?? quizState.userScores,
            users: updatedRoom.users,
            timeLeft: calculatedTimeLeft,
            shuffledOptions: shuffledData?.options ?? quizState.shuffledOptions,
            correctAnswerIndex:
                shuffledData?.correctIndex ?? quizState.correctAnswerIndex,
            selectedAnswerIndex: selectedAnswerIndex,
            userAnswers: userAnswers,
            // This already comes from parsed data
            userEmojis: updatedRoom.userEmojis ?? quizState.userEmojis,
          ),
        );

        if (updatedRoom.currentStage == GameStage.completed &&
            _currentUserId != null) {
          final achievements =
              ref.read(currentTriviaAchievementsProvider).currentAchievements;
          TriviaRoomDataSource.updateUserAchievements(
              roomId, _currentUserId!, achievements);
          TriviaRoomDataSource.updateUserAchievements(
              roomId, AppConstant.botUserId, _botManager.achievements);
        }
        _manageTimerBasedOnGameStage(updatedRoom.currentStage);
      });
    });
  }

  void _deactivateStreams() {
    if (!_streamsActive) return;
    _streamsActive = false;
    logger.i("Deactivating all streams and timers");
    _timer?.cancel();
    _timer = null;
    _lastSeenTimer?.cancel();
    _lastSeenTimer = null;
    _checkPresenceTimer?.cancel();
    _checkPresenceTimer = null;
    _roomSubscription?.cancel();
    _roomSubscription = null;
  }

  void _setupAppLifecycleListener(String roomId) {
    ref.listen(appLifecycleNotifierProvider, (previous, current) {
      state.whenData((quizState) {
        if (current == AppLifecycleStatus.resumed) {
          logger.i("App is now active, activating streams");
          _activateStreams(roomId, quizState.gameStage, quizState.users);
        } else {
          logger.i("App is now inactive, deactivating streams");
          _deactivateStreams();
        }
      });
    });
  }

  Future<void> startGame() async {
    state.whenData((quizState) async {
      if (quizState.isHost &&
          quizState.roomId != null &&
          quizState.gameStage == GameStage.created) {
        if (quizState.isOpponentBot) {
          await _botManager.updateBotLastSeen(quizState.roomId!);
        }
        if (!quizState.hasUserPaidCoins) {
          payCoins(-10);
          state = AsyncValue.data(quizState.copyWith(hasUserPaidCoins: true));
        }
        await TriviaRoomDataSource.startGame(quizState.roomId!);
      }
    });
  }

  void _startLastSeenUpdates(String roomId, GameStage stage) {
    if (_currentUserId != null) {
      TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
    }
    _lastSeenTimer?.cancel();
    _lastSeenTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (_currentUserId != null) {
          TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
        }
      },
    );
  }

  void _startPresenceChecking(String roomId, List<String> users) {
    if (_currentUserId == null || users.isEmpty) return;
    _checkPresenceTimer?.cancel();
    _checkPresenceTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        logger.i("Checking user presence at ${DateTime.now()}");
        state.whenData(
          (quizState) async {
            logger.i("Current game stage: ${quizState.gameStage}");
            if (quizState.gameStage == GameStage.active ||
                quizState.gameStage == GameStage.created) {
              logger.i("Checking for absent users...");
              if (quizState.isOpponentBot) {
                final realUserIds = quizState.users
                    .where((uid) => uid != AppConstant.botUserId)
                    .toList();
                final absentUserId =
                    await TriviaRoomDataSource.checkForAbsentUser(
                        roomId, realUserIds);
                logger.i("Absent user: $absentUserId");
                if (absentUserId != null) {
                  logger.e("Ending game due to absent user: $absentUserId");
                  TriviaRoomDataSource.endGame(
                      quizState.roomId ?? "", absentUserId);
                }
              } else {
                final absentUserId =
                    await TriviaRoomDataSource.checkForAbsentUser(
                        roomId, quizState.users);
                logger.i("Absent user: $absentUserId");
                if (absentUserId != null) {
                  logger.e("Ending game due to absent user: $absentUserId");
                  TriviaRoomDataSource.endGame(
                      quizState.roomId ?? "", absentUserId);
                }
              }
            }
            if (quizState.gameStage == GameStage.created && quizState.isHost) {
              if (quizState.isOpponentBot) {
                logger.i("Bot opponent, can start game immediately");
                startGame();
              } else {
                final allPresent = await TriviaRoomDataSource.checkUserPresence(
                    roomId, quizState.users);
                logger.i("All users present: $allPresent");
                if (allPresent) {
                  logger.i("All users present, starting game");
                  startGame();
                }
              }
            }
          },
        );
      },
    );
  }

  void _manageTimerBasedOnGameStage(GameStage stage) {
    _timer?.cancel();
    if (stage == GameStage.active) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 40),
        (timer) {
          state.whenData(
            (quizState) {
              if (quizState.timeLeft > 0) {
                state = AsyncValue.data(
                    quizState.copyWith(timeLeft: quizState.timeLeft - 0.04));
              } else {
                if (quizState.selectedAnswerIndex == null) {
                  selectAnswer(-1);
                }
              }
            },
          );
        },
      );
    }
  }

  void selectAnswer(int index) {
    state.whenData(
      (quizState) async {
        if (quizState.selectedAnswerIndex == null &&
            quizState.roomId != null &&
            _currentUserId != null &&
            quizState.gameStage == GameStage.active) {
          state =
              AsyncValue.data(quizState.copyWith(selectedAnswerIndex: index));
          if (quizState.correctAnswerIndex == index) {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(
                    field: AchievementField.correctAnswers,
                    sumResponseTime:
                        AppConstant.questionTime - quizState.timeLeft);
          } else if (index == -1) {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(field: AchievementField.unanswered);
          } else {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(
                    field: AchievementField.wrongAnswers,
                    sumResponseTime:
                        AppConstant.questionTime - quizState.timeLeft);
          }
          await TriviaRoomDataSource.storeUserAnswer(quizState.roomId!,
              _currentUserId!, quizState.questionIndex, index);
          if (quizState.isOpponentBot) {
            await _botManager.handleBotAnswer(
              roomId: quizState.roomId!,
              questionIndex: quizState.questionIndex,
              correctAnswerIndex: quizState.correctAnswerIndex,
              shuffledOptions: quizState.shuffledOptions,
              timeLeft: quizState.timeLeft,
            );
          }
          if (quizState.correctAnswerIndex == index) {
            await TriviaRoomDataSource.updateUserScore(quizState.roomId!,
                _currentUserId!, quizState.questionIndex, quizState.timeLeft);
          } else if (index == -1) {
            await TriviaRoomDataSource.updateMissedQuestions(
                quizState.roomId!, _currentUserId!);
          }
          await _checkAllUsersAnswered(quizState);
        }
      },
    );
  }

  Future<void> _checkAllUsersAnswered(DuelQuizState quizState) async {
    if (quizState.roomId == null) return;
    final allUsersAnswered = await TriviaRoomDataSource.checkAllUsersAnswered(
        quizState.roomId!, quizState.users, quizState.questionIndex);
    if (allUsersAnswered) {
      await TriviaRoomDataSource.moveToReviewStage(quizState.roomId!);
      Timer(
        const Duration(seconds: 3),
        () async {
          final updatedRoom =
              await TriviaRoomDataSource.getRoomById(quizState.roomId!);
          if (updatedRoom == null) return;
          if (updatedRoom.currentStage == GameStage.questionReview) {
            await TriviaRoomDataSource.moveToNextQuestion(quizState.roomId!,
                quizState.questionIndex, quizState.questions.length);
          }
        },
      );
    }
  }

  ShuffledData _getShuffledOptions(Question question) {
    final options = [...question.incorrectAnswers!, question.correctAnswer!];
    options.shuffle();
    final shuffledCorrectIndex = options.indexOf(question.correctAnswer!);
    return ShuffledData(options: options, correctIndex: shuffledCorrectIndex);
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  Future<void> updateUserEmoji(SelectedEmoji emoji) async {
    final String? currentRoomId = state.value?.roomId;
    final String? currentUserId = _currentUserId;

    if (currentRoomId == null || currentUserId == null) {
      logger.e('Error: roomId or userId is null. Cannot update user emoji.');
      return;
    }

    try {
      final now = Timestamp.now();
      await TriviaRoomDataSource.updateUserEmoji(
        currentRoomId,
        currentUserId,
        emoji, // Pass SelectedEmoji directly
        now,
      );
    } catch (e) {
      logger.e('Error updating user emoji in Firestore: $e');
    }
  }
}
