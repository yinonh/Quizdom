enum GameStage {
  created, // Room just created
  waiting, // Waiting for players to join/ready
  preparing, // Players ready, about to start
  active, // Game in progress
  questionReview, // Between questions, showing results
  completed // Game fully finished
}
