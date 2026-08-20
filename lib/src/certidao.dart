import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Civil-registry certificate number (Provimento CNJ 46/2015).
///
/// **Check kind:** [CheckKind.checksum] (32 digits, ISO 7064 mod 97-10 on the
/// last two). Field-range checks beyond the DV are not applied. Does not query
/// CRC / registro civil.
final class Certidao {
  const Certidao._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 32 ASCII digits.
  final String canonical;

  /// `true` when [input] has 32 digits and valid check digits.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a 32-digit certificate number.
  static Certidao? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 32) {
      return null;
    }
    if (!iso7064Mod97IsValid(digits)) {
      return null;
    }
    return Certidao._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Certidao parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('certidão', input);
    }
    return parsed;
  }

  /// Unmasked 32 digits.
  String get formatted => canonical;
}
