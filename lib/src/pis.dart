import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// PIS / PASEP / NIS / NIT (same NIT modulo 11).
///
/// **Check kind:** [CheckKind.checksum]. Does not prove Dataprev/INSS issued
/// the number.
final class Pis {
  const Pis._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  static const List<int> _weights = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// 11 ASCII digits, no mask.
  final String canonical;

  /// `true` when [input] has a valid PIS/PASEP/NIS/NIT check digit.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses [input], accepting `000.00000.00-0`.
  static Pis? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 11) {
      return null;
    }
    if (isRepeatedDigitString(digits)) {
      return null;
    }
    final body = digitsOf(digits);
    final dv = modulo11CpfStyle(weightedSum(body.sublist(0, 10), _weights));
    if (dv != body[10]) {
      return null;
    }
    return Pis._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Pis parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('PIS', input);
    }
    return parsed;
  }

  /// Mask `000.00000.00-0`.
  String get formatted =>
      insertSeparators(canonical, const [3, 5, 2, 1], const ['.', '.', '-']);
}
