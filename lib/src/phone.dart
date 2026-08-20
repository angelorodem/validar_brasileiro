import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian telephone number (Anatel numbering plan).
///
/// **Check kind:** [CheckKind.format]. 67 DDDs; landline 8 digits starting
/// `2–5`; mobile 9 digits starting with `9`. Does not prove the number is
/// assigned.
final class Phone {
  const Phone._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.format;

  /// Canonical `+55` plus 10 or 11 national digits.
  final String canonical;

  /// Official DDD codes.
  static const Set<String> ddds = {
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '21',
    '22',
    '24',
    '27',
    '28',
    '31',
    '32',
    '33',
    '34',
    '35',
    '37',
    '38',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '51',
    '53',
    '54',
    '55',
    '61',
    '62',
    '64',
    '63',
    '65',
    '66',
    '67',
    '68',
    '69',
    '71',
    '73',
    '74',
    '75',
    '77',
    '79',
    '81',
    '87',
    '82',
    '83',
    '84',
    '85',
    '88',
    '86',
    '89',
    '91',
    '93',
    '94',
    '92',
    '97',
    '95',
    '96',
    '98',
    '99',
  };

  /// `true` when [input] is a well-formed Brazilian number.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses national or `+55` numbers.
  static Phone? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null) {
      return null;
    }
    var national = digits;
    if (national.startsWith('55') &&
        (national.length == 12 || national.length == 13)) {
      national = national.substring(2);
    }
    if (national.length != 10 && national.length != 11) {
      return null;
    }
    final ddd = national.substring(0, 2);
    if (!ddds.contains(ddd)) {
      return null;
    }
    final subscriber = national.substring(2);
    if (national.length == 10) {
      final first = subscriber.codeUnitAt(0);
      if (first < 50 || first > 53) {
        return null;
      }
    } else if (!subscriber.startsWith('9')) {
      return null;
    }
    return Phone._('+55$national');
  }

  /// Parses [input] or throws [FormatException].
  static Phone parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('telefone', input);
    }
    return parsed;
  }

  /// National digits without `+55`.
  String get national => canonical.substring(3);

  /// Whether this is a 9-digit mobile subscriber.
  bool get isMobile => national.length == 11;

  /// `(00) 00000-0000` or `(00) 0000-0000`.
  String get formatted {
    final n = national;
    final ddd = n.substring(0, 2);
    if (n.length == 11) {
      return '($ddd) ${n.substring(2, 7)}-${n.substring(7)}';
    }
    return '($ddd) ${n.substring(2, 6)}-${n.substring(6)}';
  }
}
