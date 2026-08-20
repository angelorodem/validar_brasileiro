import 'check_kind.dart';

/// Form-grade email check (not a full RFC 5322 parser).
///
/// **Check kind:** [CheckKind.format]. Accepts common addresses including
/// `.br` and `.com.br`. Rejects empty values, missing `@`, domains without a
/// dot, and spaces.
final class EmailAddress {
  const EmailAddress._(this.canonical);

  /// How this value is checked.
  static const CheckKind checkKind = CheckKind.format;

  /// Trimmed address as entered (case preserved except PIX, which lowercases).
  final String canonical;

  /// `true` when [input] looks like a usable email address.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a form-grade email.
  static EmailAddress? tryParse(String input) {
    final trimmed = input.trim();
    if (!_looksLikeEmail(trimmed)) {
      return null;
    }
    return EmailAddress._(trimmed);
  }

  /// Parses or throws [FormatException].
  static EmailAddress parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throw FormatException('Invalid email.', input);
    }
    return parsed;
  }
}

/// PIX DICT emails: form-grade, lowercase, at most 77 characters.
bool isPixEmail(String input) {
  final trimmed = input.trim();
  if (trimmed.length > 77) {
    return false;
  }
  if (trimmed != trimmed.toLowerCase()) {
    return false;
  }
  return EmailAddress.isValid(trimmed);
}

bool _looksLikeEmail(String trimmed) {
  if (trimmed.isEmpty || trimmed.length >= 255) {
    return false;
  }
  final at = trimmed.indexOf('@');
  if (at <= 0 || at != trimmed.lastIndexOf('@')) {
    return false;
  }
  final local = trimmed.substring(0, at);
  final domain = trimmed.substring(at + 1);
  if (local.isEmpty || domain.length < 3) {
    return false;
  }
  if (local.length > 64) {
    return false;
  }
  if (local.contains(' ') || domain.contains(' ')) {
    return false;
  }
  if (local.startsWith('.') || local.endsWith('.') || local.contains('..')) {
    return false;
  }
  final dot = domain.lastIndexOf('.');
  if (dot <= 0 || dot == domain.length - 1) {
    return false;
  }
  final tld = domain.substring(dot + 1);
  if (tld.length < 2) {
    return false;
  }
  for (var i = 0; i < tld.length; i++) {
    final unit = tld.codeUnitAt(i);
    final letter = (unit >= 65 && unit <= 90) || (unit >= 97 && unit <= 122);
    if (!letter) {
      return false;
    }
  }
  if (domain.startsWith('.') ||
      domain.endsWith('.') ||
      domain.contains('..') ||
      domain.startsWith('-') ||
      domain.endsWith('-')) {
    return false;
  }
  return true;
}
