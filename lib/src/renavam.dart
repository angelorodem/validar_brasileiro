import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// RENAVAM vehicle identifier.
///
/// **Check kind:** [CheckKind.checksum] (modulo 11, weight sequence
/// `3,2,9,8,7,6,5,4,3,2`). Portaria DENATRAN 27/2013 defines the 11-digit
/// layout; the walkthrough matches published goldens. This does not prove the
/// vehicle exists in SENATRAN.
final class Renavam {
  const Renavam._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  static const List<int> _weights = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// 11 ASCII digits, left-padded when the input had 9 or 10 digits.
  final String canonical;

  /// `true` when [input] has a valid RENAVAM check digit.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses [input] with 9–11 digits.
  static Renavam? tryParse(String input) {
    final raw = collectDigits(input);
    if (raw == null || raw.length < 9 || raw.length > 11) {
      return null;
    }
    final digits = raw.padLeft(11, '0');
    if (isRepeatedDigitString(digits)) {
      return null;
    }
    final body = digitsOf(digits);
    final dv = modulo11CpfStyle(weightedSum(body.sublist(0, 10), _weights));
    if (dv != body[10]) {
      return null;
    }
    return Renavam._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Renavam parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('RENAVAM', input);
    }
    return parsed;
  }

  /// 11-digit canonical form.
  String get formatted => canonical;
}
