import 'check_kind.dart';
import 'format_utils.dart';
import 'normalize.dart';
import 'uf.dart';

/// Registro Geral (RG).
///
/// **Check kind:** [CheckKind.checksum] for [Uf.sp], [Uf.rj], and [Uf.mg];
/// [CheckKind.format] for every other UF (no published federal DV). [Uf] is
/// required. This does not prove SSP issued the document.
final class Rg {
  const Rg._(this.canonical, this.uf, this.checkKind);

  /// Check kind for this instance (checksum or format-only).
  final CheckKind checkKind;

  /// Canonical identifier (digits, optional trailing `X` in SP).
  final String canonical;

  /// Issuing UF, as supplied by the caller.
  final Uf uf;

  /// `true` when [input] matches the rules for [uf].
  static bool isValid(String input, {required Uf uf}) =>
      tryParse(input, uf: uf) != null;

  /// Parses an RG for [uf].
  static Rg? tryParse(String input, {required Uf uf}) {
    switch (uf) {
      case Uf.sp:
        return _parseSp(input, uf);
      case Uf.rj:
      case Uf.mg:
        return _parseRjMg(input, uf);
      default:
        return _parseFormatOnly(input, uf);
    }
  }

  /// Parses [input] or throws [FormatException].
  static Rg parse(String input, {required Uf uf}) {
    final parsed = tryParse(input, uf: uf);
    if (parsed == null) {
      throwInvalid('RG', input);
    }
    return parsed;
  }

  static Rg? _parseSp(String input, Uf uf) {
    final collected = collectAlphanumericUpper(input);
    if (collected == null || collected.length != 9) {
      return null;
    }
    final body = collected.substring(0, 8);
    if (collectDigits(body) != body) {
      return null;
    }
    if (collected[8] != _spDv(body)) {
      return null;
    }
    return Rg._(collected, uf, CheckKind.checksum);
  }

  static String _spDv(String body8) {
    var weight = 2;
    var sum = 0;
    for (var i = 7; i >= 0; i--) {
      sum += (body8.codeUnitAt(i) - 48) * weight;
      weight++;
    }
    final remainder = sum % 11;
    if (remainder == 10) {
      return 'X';
    }
    return String.fromCharCode(48 + remainder);
  }

  static Rg? _parseRjMg(String input, Uf uf) {
    var raw = collectAlphanumericUpper(input);
    if (raw == null) {
      return null;
    }
    if (uf == Uf.mg && raw.startsWith('M')) {
      raw = raw.substring(1);
    }
    final digits = collectDigits(raw);
    if (digits == null || digits.length < 8 || digits.length > 9) {
      return null;
    }
    final padded = digits.length == 8 ? digits : digits;
    final body = padded.substring(0, padded.length - 1);
    if (body.length != 7 && body.length != 8) {
      return null;
    }
    final expected = _mod10Dv(body);
    if (padded.codeUnitAt(padded.length - 1) - 48 != expected) {
      return null;
    }
    return Rg._(padded, uf, CheckKind.checksum);
  }

  static int _mod10Dv(String body) {
    var weight = 2;
    var sum = 0;
    for (var i = body.length - 1; i >= 0; i--) {
      var product = (body.codeUnitAt(i) - 48) * weight;
      if (product > 9) {
        product = (product ~/ 10) + (product % 10);
      }
      sum += product;
      weight = weight == 2 ? 1 : 2;
    }
    final remainder = sum % 10;
    if (remainder == 0) {
      return 0;
    }
    return 10 - remainder;
  }

  static Rg? _parseFormatOnly(String input, Uf uf) {
    final digits = collectDigits(input);
    if (digits == null || digits.length < 5 || digits.length > 14) {
      return null;
    }
    return Rg._(digits, uf, CheckKind.format);
  }

  /// Unmasked canonical form.
  String get formatted => canonical;
}
