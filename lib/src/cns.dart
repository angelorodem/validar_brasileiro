import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Cartão Nacional de Saúde (CNS / Cartão SUS).
///
/// **Check kind:** [CheckKind.checksum]. Definitive cards start with `1` or
/// `2`; provisional with `7`, `8`, or `9`. Both require the 15-digit weighted
/// sum (weights `15…1`) to be a multiple of 11. Does not query CADSUS.
final class Cns {
  const Cns._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 15 ASCII digits.
  final String canonical;

  /// `true` when [input] is a well-formed CNS.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a 15-digit CNS.
  static Cns? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 15) {
      return null;
    }
    final first = digits.codeUnitAt(0);
    final isDefinitive = first == 49 || first == 50; // 1 or 2
    final isProvisional = first == 55 || first == 56 || first == 57; // 7–9
    if (!isDefinitive && !isProvisional) {
      return null;
    }
    if (isDefinitive) {
      final suffix = digits.substring(11, 14);
      if (suffix != '000' && suffix != '001' && suffix != '002') {
        return null;
      }
    }
    var sum = 0;
    for (var i = 0; i < 15; i++) {
      sum += (digits.codeUnitAt(i) - 48) * (15 - i);
    }
    if (sum % 11 != 0) {
      return null;
    }
    return Cns._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Cns parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('CNS', input);
    }
    return parsed;
  }

  /// Mask `000 0000 0000 0000`.
  String get formatted =>
      insertSeparators(canonical, const [3, 4, 4, 4], const [' ', ' ', ' ']);
}
