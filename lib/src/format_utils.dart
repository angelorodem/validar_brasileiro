/// Inserts [separators] between fixed-size groups of [canonical].
String insertSeparators(
  String canonical,
  List<int> groupSizes,
  List<String> separators,
) {
  final buffer = StringBuffer();
  var index = 0;
  for (var g = 0; g < groupSizes.length; g++) {
    final end = index + groupSizes[g];
    buffer.write(canonical.substring(index, end));
    index = end;
    if (g < separators.length) {
      buffer.write(separators[g]);
    }
  }
  return buffer.toString();
}

/// Throws a [FormatException] for an invalid [type].
Never throwInvalid(String type, [String? input]) {
  throw FormatException('Invalid $type.', input);
}
