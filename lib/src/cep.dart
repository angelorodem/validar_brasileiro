import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian postal code.
///
/// **Check kind:** [CheckKind.format] (8 ASCII digits). There is no check
/// digit and this does not query Correios.
final class Cep {
  const Cep._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.format;

  /// 8 ASCII digits.
  final String canonical;

  /// `true` when [input] has exactly 8 digits.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses [input], accepting `00000-000`.
  static Cep? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 8) {
      return null;
    }
    if (isRepeatedDigitString(digits)) {
      return null;
    }
    return Cep._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static Cep parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('CEP', input);
    }
    return parsed;
  }

  /// Mask `00000-000`.
  String get formatted =>
      insertSeparators(canonical, const [5, 3], const ['-']);
}
