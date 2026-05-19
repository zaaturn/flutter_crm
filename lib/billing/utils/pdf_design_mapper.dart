String canonicalPdfDesignId(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return s;

  final upper = s.toUpperCase().replaceAll(' ', '_');

  // Accept common variants/typos from UI or older data.
  switch (upper) {
    case 'DARK_LAXURY': // typo seen in template filenames
    case 'DARK_LUXURY':
      return 'DARK_LUXURY';
    case 'CLASSIC_GOLD':
    case 'CLASSICGOLD':
    case 'CLASSIC_GOLD_TEMPLATE':
      return 'CLASSIC_GOLD';
    default:
      return upper;
  }
}

