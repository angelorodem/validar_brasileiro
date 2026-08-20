import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian vehicle plate (legacy and Mercosul).
///
/// **Check kind:** [CheckKind.format]. Legacy `LLLNNNN`, Mercosul `LLLNLNN`.
/// There is no check digit.
final class Placa {
  const Placa._(this.canonical, this.mercosul);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.format;

  /// 7 uppercase ASCII characters.
  final String canonical;

  /// `true` when this is Mercosul `LLLNLNN`.
  final bool mercosul;

  /// `true` when [input] matches either plate shape.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a legacy or Mercosul plate.
  static Placa? tryParse(String input) {
    final collected = collectAlphanumericUpper(input);
    if (collected == null || collected.length != 7) {
      return null;
    }
    if (_isLegacy(collected)) {
      return Placa._(collected, false);
    }
    if (_isMercosul(collected)) {
      return Placa._(collected, true);
    }
    return null;
  }

  /// Parses [input] or throws [FormatException].
  static Placa parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('placa', input);
    }
    return parsed;
  }

  static bool _isLegacy(String s) {
    return _letter(s, 0) &&
        _letter(s, 1) &&
        _letter(s, 2) &&
        _digit(s, 3) &&
        _digit(s, 4) &&
        _digit(s, 5) &&
        _digit(s, 6);
  }

  static bool _isMercosul(String s) {
    return _letter(s, 0) &&
        _letter(s, 1) &&
        _letter(s, 2) &&
        _digit(s, 3) &&
        _letter(s, 4) &&
        _digit(s, 5) &&
        _digit(s, 6);
  }

  static bool _letter(String s, int i) => isAsciiUpperLetter(s.codeUnitAt(i));

  static bool _digit(String s, int i) => isAsciiDigit(s.codeUnitAt(i));

  /// Legacy `AAA-0000` or Mercosul `AAA0A00`.
  String get formatted {
    if (mercosul) {
      return canonical;
    }
    return '${canonical.substring(0, 3)}-${canonical.substring(3)}';
  }
}
