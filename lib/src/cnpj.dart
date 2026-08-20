import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian CNPJ, numeric or alphanumeric (IN RFB 2.229/2024).
///
/// **Check kind:** [CheckKind.checksum] (modulo 11, `ASCII(char) - 48`).
/// Existing numeric CNPJs stay valid. This does not prove Receita Federal
/// issued the number. Prohibited letter combinations are **not** filtered —
/// that control stays with Receita Federal.
final class Cnpj {
  const Cnpj._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  static const List<int> _dv1Weights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  static const List<int> _dv2Weights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// 14 uppercase ASCII characters, no mask.
  final String canonical;

  /// `true` when [input] is a well-formed CNPJ with valid check digits.
  static bool isValid(String input) => tryParse(input) != null;

  /// Check digits `(dv1, dv2)` for a 12-character uppercase base.
  ///
  /// [base12] must already be canonical (`A–Z` / `0–9`). Throws
  /// [FormatException] when the base is the wrong length or charset.
  static (int, int) checkDigitsFor(String base12) {
    if (base12.length != 12) {
      throwInvalid('CNPJ base', base12);
    }
    final values = List<int>.filled(13, 0);
    for (var i = 0; i < 12; i++) {
      final unit = base12.codeUnitAt(i);
      final isDigit = isAsciiDigit(unit);
      final isLetter = isAsciiUpperLetter(unit);
      if (!isDigit && !isLetter) {
        throwInvalid('CNPJ base', base12);
      }
      values[i] = cnpjCharValue(unit);
    }
    final dv1 = modulo11CpfStyle(
      weightedSum(values.sublist(0, 12), _dv1Weights),
    );
    values[12] = dv1;
    final dv2 = modulo11CpfStyle(weightedSum(values, _dv2Weights));
    return (dv1, dv2);
  }

  /// Parses [input], accepting `AA.AAA.AAA/AAAA-DD` and lowercase letters.
  static Cnpj? tryParse(String input) {
    final collected = collectAlphanumericUpper(input);
    if (collected == null || collected.length != 14) {
      return null;
    }
    for (var i = 0; i < 12; i++) {
      final unit = collected.codeUnitAt(i);
      if (!isAsciiDigit(unit) && !isAsciiUpperLetter(unit)) {
        return null;
      }
    }
    if (!isAsciiDigit(collected.codeUnitAt(12)) ||
        !isAsciiDigit(collected.codeUnitAt(13))) {
      return null;
    }
    if (_isAllSameDigit(collected)) {
      return null;
    }
    final values = List<int>.filled(13, 0);
    for (var i = 0; i < 12; i++) {
      values[i] = cnpjCharValue(collected.codeUnitAt(i));
    }
    final dv1 = modulo11CpfStyle(
      weightedSum(values.sublist(0, 12), _dv1Weights),
    );
    if (dv1 != collected.codeUnitAt(12) - 48) {
      return null;
    }
    values[12] = dv1;
    final dv2 = modulo11CpfStyle(weightedSum(values, _dv2Weights));
    if (dv2 != collected.codeUnitAt(13) - 48) {
      return null;
    }
    return Cnpj._(collected);
  }

  /// Parses [input] or throws [FormatException].
  static Cnpj parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('CNPJ', input);
    }
    return parsed;
  }

  static bool _isAllSameDigit(String canonical) {
    for (var i = 0; i < canonical.length; i++) {
      if (!isAsciiDigit(canonical.codeUnitAt(i))) {
        return false;
      }
    }
    return isRepeatedDigitString(canonical);
  }

  /// Twelve-character root + branch, without check digits.
  String get base12 => canonical.substring(0, 12);

  /// Two numeric check digits.
  String get checkDigitPair => canonical.substring(12);

  /// Mask `AA.AAA.AAA/AAAA-DD`.
  String get formatted => insertSeparators(
    canonical,
    const [2, 3, 3, 4, 2],
    const ['.', '.', '/', '-'],
  );
}
