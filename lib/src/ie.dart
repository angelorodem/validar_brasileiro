import 'check_digits.dart';
import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';
import 'uf.dart';

/// Inscrição Estadual (ICMS).
///
/// **Check kind:** [CheckKind.checksum] using the UF-specific SINTEGRA/SEFAZ
/// routine. [Uf] is required. Does not query SINTEGRA.
final class Ie {
  const Ie._(this.canonical, this.uf, {required this.produtorRural});

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// Digit string, or SP rural form starting with `P`.
  final String canonical;

  /// Issuing UF.
  final Uf uf;

  /// São Paulo rural producer (`P…`) form.
  final bool produtorRural;

  /// `true` when [input] is valid for [uf].
  static bool isValid(String input, {required Uf uf}) =>
      tryParse(input, uf: uf) != null;

  /// Parses an IE for [uf].
  static Ie? tryParse(String input, {required Uf uf}) {
    if (uf == Uf.sp) {
      final rural = _spRural(input);
      if (rural != null) {
        return rural;
      }
    }
    final digits = collectDigits(input);
    if (digits == null || digits.isEmpty) {
      return null;
    }
    final ok = switch (uf) {
      Uf.ac => _ac(digits),
      Uf.al => _al(digits),
      Uf.am => _nineStandard(digits, prefix: null),
      Uf.ap => _ap(digits),
      Uf.ba => _ba(digits),
      Uf.ce => _nineStandard(digits, prefix: null),
      Uf.df => _df(digits),
      Uf.es => _nineStandard(digits, prefix: null),
      Uf.go => _go(digits),
      Uf.ma => _nineStandard(digits, prefix: '12'),
      Uf.mg => _mg(digits),
      Uf.ms => _nineStandard(digits, prefix: '28'),
      Uf.mt => _mt(digits),
      Uf.pa => _nineStandard(digits, prefix: '15'),
      Uf.pb => _nineStandard(digits, prefix: null),
      Uf.pe => _pe(digits),
      Uf.pi => _nineStandard(digits, prefix: null),
      Uf.pr => _pr(digits),
      Uf.rj => _rj(digits),
      Uf.rn => _rn(digits),
      Uf.ro => _ro(digits),
      Uf.rr => _rr(digits),
      Uf.rs => _rs(digits),
      Uf.sc => _nineStandard(digits, prefix: null),
      Uf.se => _nineStandard(digits, prefix: null),
      Uf.sp => _sp(digits),
      Uf.to => _to(digits),
    };
    if (!ok) {
      return null;
    }
    return Ie._(digits, uf, produtorRural: false);
  }

  /// Parses [input] or throws [FormatException].
  static Ie parse(String input, {required Uf uf}) {
    final parsed = tryParse(input, uf: uf);
    if (parsed == null) {
      throwInvalid('inscrição estadual', input);
    }
    return parsed;
  }

  static bool _nineStandard(String digits, {required String? prefix}) {
    if (digits.length != 9) {
      return false;
    }
    if (prefix != null && !digits.startsWith(prefix)) {
      return false;
    }
    final body = digitsOf(digits);
    return modulo11FromRight(body.sublist(0, 8)) == body[8];
  }

  static bool _ac(String digits) {
    if (digits.length != 13 || !digits.startsWith('01')) {
      return false;
    }
    final body = digitsOf(digits);
    return modulo11FromRight(body.sublist(0, 11)) == body[11] &&
        modulo11FromRight(body.sublist(0, 12)) == body[12];
  }

  static bool _al(String digits) {
    if (digits.length != 9 || !digits.startsWith('24')) {
      return false;
    }
    final body = digitsOf(digits);
    var weight = 9;
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += body[i] * weight;
      weight--;
    }
    var dv = (sum * 10) % 11;
    if (dv == 10) {
      dv = 0;
    }
    return dv == body[8];
  }

  static bool _ap(String digits) {
    if (digits.length != 9 || !digits.startsWith('03')) {
      return false;
    }
    final n = int.parse(digits);
    final int p;
    final int d;
    if (n >= 3000001 && n <= 3017000) {
      p = 5;
      d = 0;
    } else if (n >= 3017001 && n <= 3019022) {
      p = 9;
      d = 1;
    } else {
      p = 0;
      d = 0;
    }
    final body = digitsOf(digits);
    var weight = 9;
    var sum = p;
    for (var i = 0; i < 8; i++) {
      sum += body[i] * weight;
      weight--;
    }
    final remainder = sum % 11;
    var dv = 11 - remainder;
    if (dv == 10) {
      dv = 0;
    }
    if (dv == 11) {
      dv = d;
    }
    return dv == body[8];
  }

  static bool _ba(String digits) {
    if (digits.length != 8 && digits.length != 9) {
      return false;
    }
    final moduleSelector = digits.length == 8
        ? digits.codeUnitAt(0)
        : digits.codeUnitAt(1);
    final module = moduleSelector - 48 < 6 ? 10 : 11;
    final baseLen = digits.length - 2;
    final body = digitsOf(digits);
    final last = _baDigit(body.sublist(0, baseLen), module);
    if (last != body[digits.length - 1]) {
      return false;
    }
    final mid = _baDigit(body.sublist(0, baseLen)..add(last), module);
    return mid == body[digits.length - 2];
  }

  static int _baDigit(List<int> body, int module) {
    var weight = 2;
    var sum = 0;
    for (var i = body.length - 1; i >= 0; i--) {
      sum += body[i] * weight;
      weight++;
    }
    if (module == 10) {
      final remainder = sum % 10;
      return remainder == 0 ? 0 : 10 - remainder;
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  static bool _df(String digits) {
    if (digits.length != 13 || !digits.startsWith('07')) {
      return false;
    }
    final body = digitsOf(digits);
    return modulo11FromRight(body.sublist(0, 11)) == body[11] &&
        modulo11FromRight(body.sublist(0, 12)) == body[12];
  }

  static bool _go(String digits) {
    if (digits.length != 9) {
      return false;
    }
    if (!digits.startsWith('10') &&
        !digits.startsWith('11') &&
        !digits.startsWith('15')) {
      return false;
    }
    final body = digitsOf(digits);
    var weight = 9;
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += body[i] * weight;
      weight--;
    }
    final remainder = sum % 11;
    final n = int.parse(digits.substring(0, 8));
    final int dv;
    if (remainder == 0) {
      dv = 0;
    } else if (remainder == 1) {
      dv = n >= 10103105 && n <= 10119997 ? 1 : 0;
    } else {
      dv = 11 - remainder;
    }
    return dv == body[8];
  }

  static bool _mg(String digits) {
    if (digits.length != 13) {
      return false;
    }
    final body = digitsOf(digits);
    final withZero = [...body.sublist(0, 3), 0, ...body.sublist(3, 11)];
    var sum = 0;
    var alt = 1;
    for (final digit in withZero) {
      var product = digit * alt;
      if (product > 9) {
        product = (product ~/ 10) + (product % 10);
      }
      sum += product;
      alt = alt == 1 ? 2 : 1;
    }
    final dv1 = (10 - (sum % 10)) % 10;
    if (dv1 != body[11]) {
      return false;
    }
    return modulo11CpfStyle(
          weightedSum(body.sublist(0, 12), const [
            3,
            2,
            11,
            10,
            9,
            8,
            7,
            6,
            5,
            4,
            3,
            2,
          ]),
        ) ==
        body[12];
  }

  static bool _mt(String digits) {
    final padded = digits.length == 11 ? digits : digits.padLeft(11, '0');
    if (padded.length != 11) {
      return false;
    }
    if (digits.length != 9 && digits.length != 11) {
      return false;
    }
    final nine = padded.substring(padded.length - 9);
    return _nineStandard(nine, prefix: null);
  }

  static bool _pe(String digits) {
    if (digits.length == 9) {
      final body = digitsOf(digits);
      return modulo11FromRight(body.sublist(0, 7)) == body[7] &&
          modulo11FromRight(body.sublist(0, 8)) == body[8];
    }
    if (digits.length == 14) {
      final body = digitsOf(digits);
      return modulo11FromRight(body.sublist(0, 13)) == body[13];
    }
    return false;
  }

  static bool _pr(String digits) {
    if (digits.length != 10) {
      return false;
    }
    final body = digitsOf(digits);
    const w1 = [3, 2, 7, 6, 5, 4, 3, 2];
    const w2 = [4, 3, 2, 7, 6, 5, 4, 3, 2];
    if (modulo11CpfStyle(weightedSum(body.sublist(0, 8), w1)) != body[8]) {
      return false;
    }
    return modulo11CpfStyle(weightedSum(body.sublist(0, 9), w2)) == body[9];
  }

  static bool _rj(String digits) {
    if (digits.length != 8) {
      return false;
    }
    final body = digitsOf(digits);
    const weights = [2, 7, 6, 5, 4, 3, 2];
    return modulo11CpfStyle(weightedSum(body.sublist(0, 7), weights)) ==
        body[7];
  }

  static bool _rn(String digits) {
    if (digits.length != 9 && digits.length != 10) {
      return false;
    }
    if (!digits.startsWith('20')) {
      return false;
    }
    final body = digitsOf(digits);
    final base = digits.length - 1;
    var weight = base + 1;
    var sum = 0;
    for (var i = 0; i < base; i++) {
      sum += body[i] * weight;
      weight--;
    }
    var dv = (sum * 10) % 11;
    if (dv == 10) {
      dv = 0;
    }
    return dv == body[base];
  }

  static bool _ro(String digits) {
    if (digits.length == 9) {
      final body = digitsOf(digits);
      return modulo11FromRight(body.sublist(0, 8)) == body[8];
    }
    if (digits.length == 14) {
      final body = digitsOf(digits);
      var weight = 2;
      var sum = 0;
      for (var i = 12; i >= 0; i--) {
        sum += body[i] * weight;
        weight++;
        if (weight > 9) {
          weight = 2;
        }
      }
      var dv = 11 - (sum % 11);
      if (dv >= 10) {
        dv -= 10;
      }
      return dv == body[13];
    }
    return false;
  }

  static bool _rr(String digits) {
    if (digits.length != 9 || !digits.startsWith('24')) {
      return false;
    }
    final body = digitsOf(digits);
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += body[i] * (i + 1);
    }
    return sum % 9 == body[8];
  }

  static bool _rs(String digits) {
    if (digits.length != 10) {
      return false;
    }
    final body = digitsOf(digits);
    return modulo11FromRight(body.sublist(0, 9)) == body[9];
  }

  static bool _sp(String digits) {
    if (digits.length != 12) {
      return false;
    }
    final body = digitsOf(digits);
    const w1 = [1, 3, 4, 5, 6, 7, 8, 10];
    const w2 = [3, 2, 10, 9, 8, 7, 6, 5, 4, 3, 2];
    var resto = weightedSum(body.sublist(0, 8), w1) % 11;
    final dv1 = resto == 10 ? 0 : resto;
    if (dv1 != body[8]) {
      return false;
    }
    resto = weightedSum(body.sublist(0, 11), w2) % 11;
    final dv2 = resto == 10 ? 0 : resto;
    return dv2 == body[11];
  }

  static Ie? _spRural(String input) {
    final collected = collectAlphanumericUpper(input);
    if (collected == null ||
        !collected.startsWith('P') ||
        collected.length != 13) {
      return null;
    }
    final rest = collected.substring(1);
    if (collectDigits(rest) != rest) {
      return null;
    }
    final body = digitsOf(rest);
    const weights = [1, 3, 4, 5, 6, 7, 8, 10];
    final resto = weightedSum(body.sublist(0, 8), weights) % 11;
    final dv = resto == 10 ? 0 : resto;
    if (dv != body[8]) {
      return null;
    }
    return Ie._(collected, Uf.sp, produtorRural: true);
  }

  static bool _to(String digits) {
    if (digits.length == 9) {
      return _nineStandard(digits, prefix: null);
    }
    if (digits.length != 11) {
      return false;
    }
    final middle = digits.substring(2, 4);
    if (middle != '01' && middle != '02' && middle != '03') {
      return false;
    }
    final nine = digits.substring(0, 2) + digits.substring(4);
    return _nineStandard(nine, prefix: null);
  }

  /// Unmasked canonical form.
  String get formatted => canonical;
}
