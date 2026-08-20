import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian IBAN (`BR`, 29 characters).
///
/// **Check kind:** [CheckKind.checksum] (ISO 13616). BBAN is `8n+5n+10n+1a+1c`.
/// Does not prove the account exists.
final class IbanBr {
  const IbanBr._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 29 uppercase characters starting with `BR`.
  final String canonical;

  /// `true` when [input] is a checksum-valid Brazilian IBAN.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a BR IBAN.
  static IbanBr? tryParse(String input) {
    final collected = collectAlphanumericUpper(input);
    if (collected == null || collected.length != 29) {
      return null;
    }
    if (!collected.startsWith('BR')) {
      return null;
    }
    for (var i = 2; i < 27; i++) {
      if (!isAsciiDigit(collected.codeUnitAt(i))) {
        return null;
      }
    }
    if (!isAsciiUpperLetter(collected.codeUnitAt(27))) {
      return null;
    }
    final owner = collected.codeUnitAt(28);
    if (!isAsciiUpperLetter(owner) && !isAsciiDigit(owner)) {
      return null;
    }
    if (!ibanMod97IsValid(collected)) {
      return null;
    }
    return IbanBr._(collected);
  }

  /// Parses [input] or throws [FormatException].
  static IbanBr parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('IBAN BR', input);
    }
    return parsed;
  }

  /// Unmasked 29-character IBAN.
  String get formatted => canonical;
}
