import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/features/quiz_screen/duel_quiz_screen.dart';
import 'package:trivia/features/quiz_screen/solo_quiz_screen.dart';
import 'package:trivia/features/results_screen/duel_result_screen.dart';
import 'package:trivia/features/results_screen/game_canceled.dart';
import 'package:trivia/features/results_screen/solo_results_screen.dart';

import 'custom_route_by_name.dart';

final quizRoutesProvider = Provider(
  (ref) => [
    // Solo quiz route
    CustomRouteByName(
      AppRoutes.soloQuizRouteName.substring(1), // Remove leading slash
      name: SoloQuizScreen.routeName,
      builder: (context, state) => const SoloQuizScreen(),
    ),

    // Duel quiz route with room ID
    CustomRouteByNameWithId(
      '${AppRoutes.duelQuizRouteName.substring(1)}/:roomId',
      id: 'roomId',
      name: DuelQuizScreen.routeName,
      builder: (context, state, roomId) => DuelQuizScreen(roomId: roomId),
    ),

    // Results routes
    CustomRouteByName(
      SoloResultsScreen.routeName,
      name: SoloResultsScreen.routeName,
      builder: (context, state) => const SoloResultsScreen(),
    ),

    CustomRouteByNameWithId(
      '${DuelResultsScreen.routeName}/:roomId',
      id: 'roomId',
      name: DuelResultsScreen.routeName,
      builder: (context, state, roomId) => DuelResultsScreen(roomId: roomId),
    ),

    // Game canceled route
    CustomRouteByName(
      '/game-canceled',
      name: GameCanceledScreen.routeName,
      builder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        return GameCanceledScreen(
          users: extra['users'],
          userScores: extra['userScores'],
          currentUserId: extra['currentUserId'],
          opponentId: extra['opponentId'],
        );
      },
    ),
  ],
);
