import 'check_kind.dart';
import 'cnpj.dart';
import 'cpf.dart';
import 'email.dart';
import 'format_utils.dart';
import 'phone.dart';

/// PIX key syntax (Banco Central DICT types).
///
/// **Check kind:** [CheckKind.format] (union of other checks). This does not
/// prove the key is registered in DICT.
enum PixKeyType {
  /// CPF key.
  cpf,

  /// CNPJ key.
  cnpj,

  /// Email key (lowercase, max 77 characters).
  email,

  /// Phone key (`+55` mobile).
  phone,

  /// Random key (UUID).
  evp,
}

/// A syntactically valid PIX key.
final class PixKey {
  const PixKey._(this.canonical, this.type);

  /// How this identifier is checked.
  static const CheckKind checkKind = CheckKind.format;

  /// Canonical key (digits, lowercase email, `+55…`, or UUID).
  final String canonical;

  /// DICT key type.
  final PixKeyType type;

  /// `true` when [input] matches one PIX key type.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses a PIX key.
  static PixKey? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final cpf = Cpf.tryParse(trimmed);
    if (cpf != null) {
      return PixKey._(cpf.canonical, PixKeyType.cpf);
    }
    final cnpj = Cnpj.tryParse(trimmed);
    if (cnpj != null) {
      return PixKey._(cnpj.canonical, PixKeyType.cnpj);
    }
    if (isPixEmail(trimmed)) {
      return PixKey._(trimmed.toLowerCase(), PixKeyType.email);
    }
    if (trimmed.startsWith('+55')) {
      final phone = Phone.tryParse(trimmed);
      if (phone != null && phone.isMobile) {
        return PixKey._(phone.canonical, PixKeyType.phone);
      }
    }
    final uuid = _uuid(trimmed);
    if (uuid != null) {
      return PixKey._(uuid, PixKeyType.evp);
    }
    return null;
  }

  /// Parses [input] or throws [FormatException].
  static PixKey parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throwInvalid('chave PIX', input);
    }
    return parsed;
  }

  static String? _uuid(String input) {
    if (input.length != 36) {
      return null;
    }
    for (var i = 0; i < 36; i++) {
      final unit = input.codeUnitAt(i);
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        if (unit != 45) {
          return null;
        }
        continue;
      }
      final hex =
          (unit >= 48 && unit <= 57) ||
          (unit >= 97 && unit <= 102) ||
          (unit >= 65 && unit <= 70);
      if (!hex) {
        return null;
      }
    }
    return input.toLowerCase();
  }
}
