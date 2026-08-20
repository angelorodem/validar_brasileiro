import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';

/// Brazilian boleto (cobrança 47/44 or arrecadação 48).
///
/// **Check kind:** [CheckKind.checksum] (FEBRABAN modulo 10 field DVs and
/// modulo 11 barcode DV). Does not prove the slip was issued or paid.
final class Boleto {
  const Boleto._(this.canonical, this.arrecadacao);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// Digit-only linha or barcode.
  final String canonical;

  /// `true` for concessionária/arrecadação (48 digits).
  final bool arrecadacao;

  /// `true` when [input] is a well-formed boleto.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a 44/47-digit cobrança or 48-digit arrecadação number.
  static Boleto? tryParse(String input) {
    final digits = collectDigits(input);
    if (digits == null) {
      return null;
    }
    if (digits.length == 44 || digits.length == 47) {
      return _parseCobranca(digits);
    }
    if (digits.length == 48) {
      return _parseArrecadacao(digits);
    }
    return null;
  }

  /// Parses [input] or throws [FormatException].
  static Boleto parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('boleto', input);
    }
    return parsed;
  }

  static Boleto? _parseCobranca(String digits) {
    final barcode = digits.length == 44 ? digits : _linhaToBarcode(digits);
    if (barcode == null || barcode.length != 44) {
      return null;
    }
    if (digits.length == 47 && !_linhaFieldsOk(digits)) {
      return null;
    }
    final body = digitsOf(barcode);
    if (_cobrancaBarcodeDv(body) != body[4]) {
      return null;
    }
    return Boleto._(digits, false);
  }

  static bool _linhaFieldsOk(String linha) {
    if (!_fieldOk(linha.substring(0, 9), linha.codeUnitAt(9) - 48)) {
      return false;
    }
    if (!_fieldOk(linha.substring(10, 20), linha.codeUnitAt(20) - 48)) {
      return false;
    }
    return _fieldOk(linha.substring(21, 31), linha.codeUnitAt(31) - 48);
  }

  static bool _fieldOk(String field, int dv) {
    return modulo10FromRight(digitsOf(field)) == dv;
  }

  static String? _linhaToBarcode(String linha) {
    final campo1 = linha.substring(0, 9);
    final campo2 = linha.substring(10, 20);
    final campo3 = linha.substring(21, 31);
    final dv = linha[32];
    final campo5 = linha.substring(33, 47);
    return campo1.substring(0, 4) +
        dv +
        campo5 +
        campo1.substring(4) +
        campo2 +
        campo3;
  }

  static int _cobrancaBarcodeDv(List<int> barcode) {
    var weight = 2;
    var sum = 0;
    for (var i = 43; i >= 0; i--) {
      if (i == 4) {
        continue;
      }
      sum += barcode[i] * weight;
      weight++;
      if (weight > 9) {
        weight = 2;
      }
    }
    final remainder = 11 - (sum % 11);
    if (remainder == 0 || remainder == 10 || remainder == 11) {
      return 1;
    }
    return remainder;
  }

  static Boleto? _parseArrecadacao(String digits) {
    if (digits.codeUnitAt(0) != 56) {
      return null;
    }
    for (var block = 0; block < 4; block++) {
      final start = block * 12;
      final field = digits.substring(start, start + 11);
      final dv = digits.codeUnitAt(start + 11) - 48;
      final valueType = digits.codeUnitAt(2) - 48;
      final useMod11 = valueType == 8 || valueType == 9;
      final expected = useMod11
          ? modulo11FromRight(digitsOf(field))
          : modulo10FromRight(digitsOf(field));
      if (expected != dv) {
        return null;
      }
    }
    return Boleto._(digits, true);
  }

  /// Unmasked digits.
  String get formatted => canonical;
}
