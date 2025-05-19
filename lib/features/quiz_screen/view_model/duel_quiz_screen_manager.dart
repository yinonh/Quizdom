import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/global_providers/app_lifecycle_provider.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
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
    required TriviaUser? opponent,
    required TriviaUser? currentUser,
    int? selectedAnswerIndex,
    String? roomId,
    @Default({}) Map<String, Map<int, int>> userAnswers,
    @Default(false) bool isHost,
    @Default(false) bool isOpponentBot,
  }) = _DuelQuizState;
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

  // Instance of BotManager to handle bot-related functionality
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

    // Handle opponent data
    TriviaUser? opponent;
    if (isOpponentBot) {
      // Create a bot user using BotManager
      opponent = BotManager.createBotUser();
    } else {
      // Get real user data
      opponent = await UserDataSource.getUserById(opponentID);
    }

    final currentUser = ref.read(authProvider).currentUser;

    if (room == null || room.roomId == null) {
      throw Exception("Room not initialized correctly");
    }

    // Listen to app lifecycle changes
    _setupAppLifecycleListener(room.roomId!);

    _activateStreams(room.roomId!, room.currentStage, room.users);

    final initialShuffledData = _getShuffledOptions(response![0]);

    ref.onDispose(() {
      _deactivateStreams();
      _botManager.dispose();
    });

    return DuelQuizState(
      questions: response,
      timeLeft: room.questionDuration.toDouble(),
      questionIndex: room.currentQuestionIndex,
      shuffledOptions: initialShuffledData.options,
      correctAnswerIndex: initialShuffledData.correctIndex,
      selectedAnswerIndex: null,
      categoryName: room.categoryId.toString(),
      gameStage: room.currentStage,
      userScores: room.userScores ?? {},
      users: room.users,
      opponent: opponent,
      currentUser: currentUser,
      roomId: room.roomId,
      isHost: _currentUserId == room.hostUserId,
      isOpponentBot: isOpponentBot,
    );
  }

  void _activateStreams(String roomId, GameStage stage, List<String> users) {
    if (_streamsActive) return;
    _streamsActive = true;

    logger.i("Activating all streams and timers");

    // Set up Firebase room stream
    _setupRoomSubscription(roomId);

    // Set up lastSeen updates
    _startLastSeenUpdates(roomId, stage);

    // Set up presence checking
    _startPresenceChecking(roomId, users);

    // Immediately update lastSeen to show user is active
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
        // If game stage changed from created to something else, start the lastSeen updates
        if (quizState.gameStage == GameStage.created &&
            updatedRoom.currentStage != GameStage.created) {
          // Cancel any existing timer first
          _lastSeenTimer?.cancel();

          // Start regular lastSeen updates
          _lastSeenTimer = Timer.periodic(
            const Duration(seconds: 3),
            (_) {
              if (_currentUserId != null) {
                TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
              }
            },
          );
        }

        // Calculate time left based on server timestamp
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
            // If somehow the timestamp wasn't set, update it now
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

        // Get the room snapshot from Firestore (assuming we have it from stream)
        final roomDoc = updatedRoom.toJson();
        final userAnswers = TriviaRoomDataSource.parseUserAnswers(roomDoc);

        // If question index changed, get new shuffled options
        ShuffledData? shuffledData;
        if (updatedRoom.currentQuestionIndex != quizState.questionIndex) {
          if (updatedRoom.currentQuestionIndex < quizState.questions.length) {
            shuffledData = _getShuffledOptions(
                quizState.questions[updatedRoom.currentQuestionIndex]);
          }
        }

        // Determine selected answer index from user answers
        int? selectedAnswerIndex = quizState.selectedAnswerIndex;
        if (_currentUserId != null &&
            userAnswers.containsKey(_currentUserId) &&
            userAnswers[_currentUserId]!
                .containsKey(updatedRoom.currentQuestionIndex)) {
          selectedAnswerIndex =
              userAnswers[_currentUserId]![updatedRoom.currentQuestionIndex];
        } else if (updatedRoom.currentQuestionIndex !=
            quizState.questionIndex) {
          // Reset selected answer when moving to new question
          selectedAnswerIndex = null;
        }

        // Update state with new room data
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
          ),
        );

        // If game is just completed, save achievements to Firestore
        if (updatedRoom.currentStage == GameStage.completed &&
            _currentUserId != null) {
          // Get current achievements from the provider
          final achievements =
              ref.read(currentTriviaAchievementsProvider).currentAchievements;

          // Update achievements in Firestore
          TriviaRoomDataSource.updateUserAchievements(
            roomId,
            _currentUserId!,
            achievements,
          );
          TriviaRoomDataSource.updateUserAchievements(
            roomId,
            AppConstant.botUserId,
            _botManager.achievements,
          );
        }

        // Manage timer based on game stage
        _manageTimerBasedOnGameStage(updatedRoom.currentStage);
      });
    });
  }

  void _deactivateStreams() {
    if (!_streamsActive) return;
    _streamsActive = false;

    logger.i("Deactivating all streams and timers");

    // Cancel all timers and subscriptions
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
    // Watch app lifecycle status changes
    ref.listen(appLifecycleNotifierProvider, (previous, current) {
      state.whenData((quizState) {
        if (current == AppLifecycleStatus.resumed) {
          // App is in foreground
          logger.i("App is now active, activating streams");
          _activateStreams(roomId, quizState.gameStage, quizState.users);
        } else {
          // App is in background
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
        // Bot-specific logic - update last seen timestamp
        if (quizState.isOpponentBot) {
          await _botManager.updateBotLastSeen(quizState.roomId!);
        }

        await TriviaRoomDataSource.startGame(quizState.roomId!);
      }
    });
  }

  // Method to set bot accuracy (can be called from outside if needed)
  void setBotAccuracy(double accuracy) {
    _botManager.setBotAccuracy(accuracy);
  }

  void _startLastSeenUpdates(String roomId, GameStage stage) {
    // Update lastSeen immediately regardless of stage
    if (_currentUserId != null) {
      TriviaRoomDataSource.updateLastSeen(roomId, _currentUserId!);
    }

    // Set up timer to update lastSeen every 3 seconds
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

            // Check for absent users during active game
            if (quizState.gameStage == GameStage.active ||
                quizState.gameStage == GameStage.created) {
              logger.i("Checking for absent users...");

              // Skip absence checks for bot users
              if (quizState.isOpponentBot) {
                // For bot opponents, we only check if the human player is absent
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
                // Regular absence check for human players
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

            // Check if both users are present during created stage
            if (quizState.gameStage == GameStage.created && quizState.isHost) {
              // When playing against bot, we don't need to wait for presence
              if (quizState.isOpponentBot) {
                // For bot games, we can start immediately
                logger.i("Bot opponent, can start game immediately");
                startGame();
              } else {
                // For human opponents, check if all users are present
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
    // Cancel existing timer
    _timer?.cancel();

    if (stage == GameStage.active) {
      // Start question timer
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

  // Update user's answer in Firestore
  void selectAnswer(int index) {
    state.whenData(
      (quizState) async {
        if (quizState.selectedAnswerIndex == null &&
            quizState.roomId != null &&
            _currentUserId != null &&
            quizState.gameStage == GameStage.active) {
          // Only allow during active stage
          // First update local state
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

          // Store user's answer in Firestore
          await TriviaRoomDataSource.storeUserAnswer(quizState.roomId!,
              _currentUserId!, quizState.questionIndex, index);

          // Bot-specific logic - handle bot answer when playing against bot
          if (quizState.isOpponentBot) {
            await _botManager.handleBotAnswer(
              roomId: quizState.roomId!,
              questionIndex: quizState.questionIndex,
              correctAnswerIndex: quizState.correctAnswerIndex,
              shuffledOptions: quizState.shuffledOptions,
              timeLeft: quizState.timeLeft,
            );
          }

          // Update score if answer is correct
          if (quizState.correctAnswerIndex == index) {
            await TriviaRoomDataSource.updateUserScore(quizState.roomId!,
                _currentUserId!, quizState.questionIndex, quizState.timeLeft);
          } else if (index == -1) {
            // Update missed questions in Firestore
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

    // Check if all users have answered
    final allUsersAnswered = await TriviaRoomDataSource.checkAllUsersAnswered(
        quizState.roomId!, quizState.users, quizState.questionIndex);

    if (allUsersAnswered) {
      // Move to review stage
      await TriviaRoomDataSource.moveToReviewStage(quizState.roomId!);

      // Schedule next question after 3 seconds
      Timer(
        const Duration(seconds: 3),
        () async {
          // Get latest room data
          final updatedRoom =
              await TriviaRoomDataSource.getRoomById(quizState.roomId!);
          if (updatedRoom == null) return;

          // Only proceed if we're still in the review stage
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
}
