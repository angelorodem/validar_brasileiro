/// Brazilian document and form validators for Dart and Flutter.
///
/// Every type documents its [CheckKind]. `isValid` means the value is
/// well-formed and passes the published checksum or format table — it does
/// **not** mean a government registry issued it.
library;

export 'src/boleto.dart';
export 'src/cartao.dart';
export 'src/cep.dart';
export 'src/certidao.dart';
export 'src/check_kind.dart';
export 'src/cnh.dart';
export 'src/cnpj.dart';
export 'src/cns.dart';
export 'src/cpf.dart';
export 'src/email.dart' show EmailAddress, isPixEmail;
export 'src/form.dart';
export 'src/iban_br.dart';
export 'src/ie.dart';
export 'src/nfe_chave.dart';
export 'src/normalize.dart'
    show cnpjCharValue, cnpjCharValues, collectAlphanumericUpper;
export 'src/phone.dart';
export 'src/pis.dart';
export 'src/pix.dart';
export 'src/placa.dart';
export 'src/processo_cnj.dart';
export 'src/renavam.dart';
export 'src/rg.dart';
export 'src/titulo_eleitor.dart';
export 'src/uf.dart';
