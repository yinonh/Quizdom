import 'dart:convert';

Map<String, dynamic> decodeFields(Map<String, dynamic> result) {
  return {
    'difficulty': utf8.decode(base64.decode(result['difficulty'])),
    'category': utf8.decode(base64.decode(result['category'])),
    'question': utf8.decode(base64.decode(result['question'])),
    'correct_answer': utf8.decode(base64.decode(result['correct_answer'])),
    'incorrect_answers': (result['incorrect_answers'] as List).map((answer) {
      return utf8.decode(base64.decode(answer));
    }).toList(),
  };
}
