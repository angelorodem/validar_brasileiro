/// Generic field rules used by forms. These are not Brazilian documents.
library;

/// `true` when [value] is null or empty after trim.
bool isBlank(String? value) => value == null || value.trim().isEmpty;

/// Parses [value] as an integer or decimal number (`.` or `,`).
num? parseNumber(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim().replaceAll(' ', '');
  if (trimmed.isEmpty) {
    return null;
  }
  final normalized = trimmed.contains(',') && !trimmed.contains('.')
      ? trimmed.replaceAll(',', '.')
      : trimmed.replaceAll(',', '');
  return num.tryParse(normalized);
}
