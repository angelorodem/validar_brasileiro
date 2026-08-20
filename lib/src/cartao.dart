import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Payment-card PAN (ISO/IEC 7812 Luhn).
///
/// **Check kind:** [CheckKind.checksum]. Brand detection is out of scope.
final class Cartao {
  const Cartao._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// Digit-only PAN.
  final String canonical;

  /// `true` when [input] is 13–19 digits and passes Luhn.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a PAN.
  static Cartao? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length < 13 || digits.length > 19) {
      return null;
    }
    if (!luhnIsValid(digits)) {
      return null;
    }
    return Cartao._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Cartao parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('cartão', input);
    }
    return parsed;
  }

  /// Unmasked PAN (callers should not log this).
  String get formatted => canonical;
}
