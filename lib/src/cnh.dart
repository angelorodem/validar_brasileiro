import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// CNH registro number (11 digits).
///
/// **Check kind:** [CheckKind.checksum] (modulo 11 with *desconto* when DV1
/// would be 10). CONTRAN 511/2014 defines the 9+2 layout; the walkthrough is
/// the community cross-check used with published goldens. This does not prove
/// SENATRAN issued the licence.
final class Cnh {
  const Cnh._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 11 ASCII digits, no mask.
  final String canonical;

  /// `true` when [input] has valid CNH check digits.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses [input].
  static Cnh? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 11) {
      return null;
    }
    if (isRepeatedDigitString(digits)) {
      return null;
    }
    final body = digitsOf(digits);
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += body[i] * (9 - i);
    }
    var remainder = sum % 11;
    final int dv1;
    final int decrement;
    if (remainder >= 10) {
      dv1 = 0;
      decrement = 2;
    } else {
      dv1 = remainder;
      decrement = 0;
    }
    if (dv1 != body[9]) {
      return null;
    }
    sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += body[i] * (i + 1);
    }
    remainder = sum % 11;
    var dv2 = remainder >= 10 ? 0 : remainder - decrement;
    if (dv2 < 0) {
      dv2 += 11;
    }
    if (dv2 != body[10]) {
      return null;
    }
    return Cnh._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Cnh parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('CNH', input);
    }
    return parsed;
  }

  /// Unmasked 11-digit registro.
  String get formatted => canonical;
}
