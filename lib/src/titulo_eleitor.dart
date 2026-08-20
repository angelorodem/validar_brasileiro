import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';
import 'uf.dart';

/// Título de eleitor (TSE).
///
/// **Check kind:** [CheckKind.checksum]. Resolução TSE 20.132/1998 Art. 10
/// gives modulo 11 and the 8+2+2 layout. Weights `2…9` / `7,8,9` and the SP/MG
/// rule (remainder `0` → DV `1`) come from the long-standing algorithm notes
/// used with published goldens. This does not prove the title is in the
/// cadastro eleitoral.
final class TituloEleitor {
  const TituloEleitor._(this.canonical);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.checksum;

  /// 12 ASCII digits, left-padded when needed.
  final String canonical;

  /// `true` when [input] has valid título check digits and a UF code `01–28`.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a 12-digit título (`NNNNNNNNUUDV`).
  static TituloEleitor? tryParse(String input) {
    final raw = collectDigits(input);
    if (raw == null || raw.length < 12 || raw.length > 13) {
      return null;
    }
    final digits = raw.length == 13 ? raw.substring(raw.length - 12) : raw;
    if (digits.length != 12) {
      return null;
    }
    final ufCode = int.tryParse(digits.substring(8, 10));
    if (ufCode == null || ufCode < 1 || ufCode > 28) {
      return null;
    }
    final special = ufCode == 1 || ufCode == 2;
    final body = digitsOf(digits);
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += body[i] * (i + 2);
    }
    var dv1 = sum % 11;
    if (dv1 == 10) {
      dv1 = 0;
    } else if (dv1 == 0 && special) {
      dv1 = 1;
    }
    if (dv1 != body[10]) {
      return null;
    }
    sum = body[8] * 7 + body[9] * 8 + dv1 * 9;
    var dv2 = sum % 11;
    if (dv2 == 10) {
      dv2 = 0;
    } else if (dv2 == 0 && special) {
      dv2 = 1;
    }
    if (dv2 != body[11]) {
      return null;
    }
    return TituloEleitor._(digits);
  }

  /// Parses [input] or throws [FormatException].
  static TituloEleitor parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('título de eleitor', input);
    }
    return parsed;
  }

  /// Electoral UF code `01–27` or `28` (exterior).
  String get ufCode => canonical.substring(8, 10);

  /// Federative unit when the code is `01–27`.
  Uf? get uf {
    const order = [
      Uf.sp,
      Uf.mg,
      Uf.rj,
      Uf.rs,
      Uf.ba,
      Uf.pr,
      Uf.ce,
      Uf.pe,
      Uf.sc,
      Uf.go,
      Uf.ma,
      Uf.pb,
      Uf.pa,
      Uf.es,
      Uf.pi,
      Uf.rn,
      Uf.al,
      Uf.mt,
      Uf.ms,
      Uf.df,
      Uf.se,
      Uf.am,
      Uf.ro,
      Uf.ac,
      Uf.ap,
      Uf.rr,
      Uf.to,
    ];
    final code = int.parse(ufCode);
    if (code < 1 || code > 27) {
      return null;
    }
    return order[code - 1];
  }

  /// Mask `0000 0000 0000`.
  String get formatted =>
      insertSeparators(canonical, const [4, 4, 4], const [' ', ' ']);
}
