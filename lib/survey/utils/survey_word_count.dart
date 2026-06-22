/// Matches backend `surveys.services.count_words`.
int surveyWordCount(String text) {
  if (text.trim().isEmpty) return 0;
  return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}

String truncateToWordLimit(String text, int maxWords) {
  if (maxWords <= 0) return '';
  final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length <= maxWords) return text;
  return words.take(maxWords).join(' ');
}
