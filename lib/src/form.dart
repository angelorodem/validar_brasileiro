import 'boleto.dart';
import 'cartao.dart';
import 'cep.dart';
import 'certidao.dart';
import 'cnh.dart';
import 'cnpj.dart';
import 'cns.dart';
import 'cpf.dart';
import 'email.dart';
import 'iban_br.dart';
import 'ie.dart';
import 'nfe_chave.dart';
import 'phone.dart';
import 'pis.dart';
import 'pix.dart';
import 'placa.dart';
import 'processo_cnj.dart';
import 'renavam.dart';
import 'rg.dart';
import 'rules.dart';
import 'titulo_eleitor.dart';
import 'uf.dart';

/// Flutter `FormField` / `TextFormField` style validator.
///
/// Returns `null` when the value is accepted, otherwise a message string
/// (never a `List.toString()` dump).
typedef FieldValidator = String? Function(String? value);

/// Runs [rules] in order and returns the first error.
FieldValidator all(Iterable<FieldValidator> rules) {
  final snapshot = List<FieldValidator>.unmodifiable(rules);
  return (value) {
    for (final rule in snapshot) {
      final error = rule(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  };
}

/// Rejects null/blank values.
FieldValidator required({String message = 'Campo obrigatório'}) {
  return (value) => isBlank(value) ? message : null;
}

/// Applies [required] only when [condition] is true.
FieldValidator requiredWhen(
  bool condition, {
  String message = 'Campo obrigatório',
}) {
  if (!condition) {
    return (_) => null;
  }
  return required(message: message);
}

/// Requires [value] to equal [other].
FieldValidator equalsTo(
  String other, {
  String message = 'Valores não conferem',
}) {
  return (value) => value == other ? null : message;
}

/// Minimum trimmed length.
FieldValidator minLength(int n, {String? message}) {
  final text = message ?? 'Mínimo de $n caracteres';
  return (value) {
    if (value == null || value.length < n) {
      return text;
    }
    return null;
  };
}

/// Maximum length.
FieldValidator maxLength(int n, {String? message}) {
  final text = message ?? 'Máximo de $n caracteres';
  return (value) {
    if (value != null && value.length > n) {
      return text;
    }
    return null;
  };
}

/// Minimum numeric value.
FieldValidator minValue(num n, {String? message}) {
  final text = message ?? 'Valor mínimo: $n';
  return (value) {
    final parsed = parseNumber(value);
    if (parsed == null || parsed < n) {
      return text;
    }
    return null;
  };
}

/// Maximum numeric value.
FieldValidator maxValue(num n, {String? message}) {
  final text = message ?? 'Valor máximo: $n';
  return (value) {
    final parsed = parseNumber(value);
    if (parsed == null || parsed > n) {
      return text;
    }
    return null;
  };
}

FieldValidator _doc(
  bool Function(String input) check, {
  required String message,
}) {
  return (value) {
    if (value == null || !check(value)) {
      return message;
    }
    return null;
  };
}

/// CPF checksum validator.
FieldValidator cpf({String message = 'CPF inválido'}) =>
    _doc(Cpf.isValid, message: message);

/// CNPJ checksum validator (numeric and alphanumeric).
FieldValidator cnpj({String message = 'CNPJ inválido'}) =>
    _doc(Cnpj.isValid, message: message);

/// Email format validator.
FieldValidator email({String message = 'E-mail inválido'}) =>
    _doc(EmailAddress.isValid, message: message);

/// PIS/PASEP/NIS/NIT checksum validator.
FieldValidator pis({String message = 'PIS inválido'}) =>
    _doc(Pis.isValid, message: message);

/// CNH checksum validator.
FieldValidator cnh({String message = 'CNH inválida'}) =>
    _doc(Cnh.isValid, message: message);

/// RENAVAM checksum validator.
FieldValidator renavam({String message = 'RENAVAM inválido'}) =>
    _doc(Renavam.isValid, message: message);

/// Título de eleitor checksum validator.
FieldValidator tituloEleitor({String message = 'Título de eleitor inválido'}) =>
    _doc(TituloEleitor.isValid, message: message);

/// CNS checksum validator.
FieldValidator cns({String message = 'CNS inválido'}) =>
    _doc(Cns.isValid, message: message);

/// CEP format validator.
FieldValidator cep({String message = 'CEP inválido'}) =>
    _doc(Cep.isValid, message: message);

/// Brazilian phone format validator.
FieldValidator phone({String message = 'Telefone inválido'}) =>
    _doc(Phone.isValid, message: message);

/// Vehicle plate format validator.
FieldValidator placa({String message = 'Placa inválida'}) =>
    _doc(Placa.isValid, message: message);

/// PIX key syntax validator.
FieldValidator pix({String message = 'Chave PIX inválida'}) =>
    _doc(PixKey.isValid, message: message);

/// Payment-card Luhn validator.
FieldValidator cartao({String message = 'Cartão inválido'}) =>
    _doc(Cartao.isValid, message: message);

/// NF-e access key validator.
FieldValidator nfeChave({String message = 'Chave NF-e inválida'}) =>
    _doc(NfeChave.isValid, message: message);

/// CNJ process number validator.
FieldValidator processoCnj({String message = 'Processo inválido'}) =>
    _doc(ProcessoCnj.isValid, message: message);

/// Civil certificate validator.
FieldValidator certidao({String message = 'Certidão inválida'}) =>
    _doc(Certidao.isValid, message: message);

/// Brazilian IBAN validator.
FieldValidator ibanBr({String message = 'IBAN inválido'}) =>
    _doc(IbanBr.isValid, message: message);

/// Boleto validator.
FieldValidator boleto({String message = 'Boleto inválido'}) =>
    _doc(Boleto.isValid, message: message);

/// Inscrição Estadual validator for [uf].
FieldValidator ie(Uf uf, {String message = 'Inscrição estadual inválida'}) {
  return _doc((input) => Ie.isValid(input, uf: uf), message: message);
}

/// RG validator for [uf].
FieldValidator rg(Uf uf, {String message = 'RG inválido'}) {
  return _doc((input) => Rg.isValid(input, uf: uf), message: message);
}
