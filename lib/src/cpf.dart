import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian CPF (Cadastro de Pessoas Físicas).
///
/// **Check kind:** [CheckKind.checksum] (modulo 11). This does not prove the
/// CPF was issued by Receita Federal.
final class Cpf {
  const Cpf._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 11 ASCII digits, no mask.
  final String canonical;

  /// `true` when [input] is a well-formed CPF with valid check digits.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses [input], accepting the mask `000.000.000-00`.
  static Cpf? tryParse(String input) {
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
      sum += body[i] * (10 - i);
    }
    if (modulo11CpfStyle(sum) != body[9]) {
      return null;
    }
    sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += body[i] * (11 - i);
    }
    if (modulo11CpfStyle(sum) != body[10]) {
      return null;
    }
    return Cpf._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Cpf parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('CPF', input);
    }
    return parsed;
  }

  /// Mask `000.000.000-00`.
  String get formatted =>
      insertSeparators(canonical, const [3, 3, 3, 2], const ['.', '.', '-']);
}
