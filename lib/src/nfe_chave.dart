import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// NF-e / NFC-e access key (44 digits).
///
/// **Check kind:** [CheckKind.checksum] (modulo 11 on the first 43 digits).
/// Models `55` (NF-e) and `65` (NFC-e). Does not prove the invoice exists.
final class NfeChave {
  const NfeChave._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  static const Set<String> _cufs = {
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '31',
    '32',
    '33',
    '35',
    '41',
    '42',
    '43',
    '50',
    '51',
    '52',
    '53',
  };

  /// 44 ASCII digits.
  final String canonical;

  /// `true` when [input] is a well-formed access key.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a 44-digit key.
  static NfeChave? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null || digits.length != 44) {
      return null;
    }
    final cuf = digits.substring(0, 2);
    if (!_cufs.contains(cuf)) {
      return null;
    }
    final model = digits.substring(20, 22);
    if (model != '55' && model != '65') {
      return null;
    }
    final body = digitsOf(digits.substring(0, 43));
    if (modulo11FromRight(body) != digits.codeUnitAt(43) - 48) {
      return null;
    }
    return NfeChave._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static NfeChave parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('chave NF-e', input);
    }
    return parsed;
  }

  /// Unmasked 44 digits.
  String get formatted => canonical;
}
