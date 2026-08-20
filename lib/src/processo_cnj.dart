import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Número único de processo judicial (CNJ Resolução 65/2008).
///
/// **Check kind:** [CheckKind.checksum] (ISO 7064 mod 97-10). Verification
/// concatenates sequence + year + justice + tribunal + origin + DV and
/// requires remainder `1`. Does not query DataJud.
final class ProcessoCnj {
  const ProcessoCnj._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 20 ASCII digits.
  final String canonical;

  /// `true` when [input] is a well-formed CNJ process number.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses `NNNNNNN-DD.AAAA.J.TR.OOOO`.
  static ProcessoCnj? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 20) {
      return null;
    }
    final justice = digits.codeUnitAt(13) - 48;
    if (justice < 1 || justice > 9) {
      return null;
    }
    final rearranged =
        digits.substring(0, 7) +
        digits.substring(9, 20) +
        digits.substring(7, 9);
    if (!iso7064Mod97IsValid(rearranged)) {
      return null;
    }
    return ProcessoCnj._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static ProcessoCnj parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('processo CNJ', input);
    }
    return parsed;
  }

  /// Mask `NNNNNNN-DD.AAAA.J.TR.OOOO`.
  String get formatted => insertSeparators(
    canonical,
    const [7, 2, 4, 1, 2, 4],
    const ['-', '.', '.', '.', '.'],
  );
}
