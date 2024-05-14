import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/server.dart';

import 'package:trivia/models/trivia_categories.dart';

part 'trivia_api_provider.freezed.dart';
part 'trivia_api_provider.g.dart';

@freezed
class TriviaApiState with _$TriviaApiState {
  const factory TriviaApiState({
    required Dio client,
  }) = _TriviaApiState;
}

@riverpod
class TriviaApi extends _$TriviaApi {
  @override
  TriviaApiState build() {
    return TriviaApiState(client: ref.watch(dioProvider));
  }

  Future<TriviaCategories> getCategories() async {
    final response = await state.client.get("api_category.php");
    if (response.statusCode == 200) {
      TriviaCategories x = TriviaCategories.fromJson(response.data);
      return x;
    } else {
      throw Exception('Failed to load trivia data');
    }
  }
}
