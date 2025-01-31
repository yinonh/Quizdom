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

String formatNumber(int number) {
  if (number >= 1000000) {
    double result = number / 1000000;
    // Format to 1 decimal place if needed
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M';
  } else if (number >= 1000) {
    double result = number / 1000;
    // Format to 1 decimal place if needed
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K';
  }
  return number.toString();
}
