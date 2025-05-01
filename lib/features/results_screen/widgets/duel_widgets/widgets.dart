// TODO: temp change that
import 'package:trivia/data/models/trivia_room.dart';

int getUserScore(TriviaRoom room, String userId) {
  final userIndex = room.users.indexOf(userId);
  if (userIndex >= 0 && userIndex < (room.userScores?.length ?? 0)) {
    return room.userScores![userIndex];
  }
  return 0;
}
