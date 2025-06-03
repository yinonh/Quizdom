import 'package:flutter_riverpod/flutter_riverpod.dart';

final newUserRegistrationProvider =
    StateNotifierProvider<NewUserRegistrationNotifier, bool>((ref) {
  return NewUserRegistrationNotifier();
});

class NewUserRegistrationNotifier extends StateNotifier<bool> {
  NewUserRegistrationNotifier() : super(false);

  void setNewUser(bool isNewUser) {
    state = isNewUser;
  }

  void clearNewUser() {
    state = false;
  }
}
