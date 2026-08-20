import 'package:test/test.dart';
import 'package:validar_brasileiro/src/check_digits.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  test('PIS golden', () {
    expect(Pis.isValid('100.27230.88-8'), isTrue);
    expect(Pis.isValid('10027230887'), isFalse);
    expect(Pis.isValid('00000000000'), isFalse);
  });

  test('CNH goldens including desconto path', () {
    expect(Cnh.isValid('62472927637'), isTrue);
    expect(Cnh.isValid('84718735264'), isTrue);
    expect(Cnh.isValid('00000000000'), isFalse);
    expect(Cnh.isValid('62472927638'), isFalse);
  });

  test('RENAVAM goldens', () {
    expect(Renavam.isValid('63977791104'), isTrue);
    expect(Renavam.isValid('72176426415'), isTrue);
    expect(Renavam.isValid('63977791105'), isFalse);
  });

  test('título de eleitor golden', () {
    expect(TituloEleitor.isValid('004356870906'), isTrue);
    final titulo = TituloEleitor.parse('0043 5687 0906');
    expect(titulo.uf, Uf.sc);
    expect(TituloEleitor.isValid('004356870907'), isFalse);
  });

  test('CNS weighted sum multiple of 11', () {
    final cns = _completeCns('12000000000000');
    expect(Cns.isValid(cns), isTrue);
    expect(Cns.isValid('${cns.substring(0, 14)}9'), isFalse);
    expect(Cns.isValid('300000000000000'), isFalse);
  });

  test('CEP format only', () {
    expect(Cep.isValid('01310-100'), isTrue);
    expect(Cep.isValid('00000000'), isFalse);
    expect(Cep.parse('01310100').formatted, '01310-100');
  });

  test('phone DDD and subscriber rules', () {
    expect(Phone.isValid('(11) 99999-9999'), isTrue);
    expect(Phone.isValid('+55 11 3333-3333'), isTrue);
    expect(Phone.isValid('1133333333'), isTrue);
    expect(Phone.isValid('11999999999'), isTrue);
    expect(Phone.isValid('11099999999'), isFalse);
    expect(Phone.isValid('1033333333'), isFalse);
  });

  test('placa legacy and Mercosul', () {
    expect(Placa.isValid('ABC-1234'), isTrue);
    expect(Placa.isValid('ABC1D23'), isTrue);
    expect(Placa.isValid('abc1d23'), isTrue);
    expect(Placa.isValid('ABCD123'), isFalse);
  });

  test('PIX union', () {
    expect(PixKey.parse('529.982.247-25').type, PixKeyType.cpf);
    expect(PixKey.parse('12.ABC.345/01DE-35').type, PixKeyType.cnpj);
    expect(PixKey.parse('pix@bcb.gov.br').type, PixKeyType.email);
    expect(PixKey.parse('+5511999999999').type, PixKeyType.phone);
    expect(
      PixKey.parse('123e4567-e89b-12d3-a456-426655440000').type,
      PixKeyType.evp,
    );
    expect(PixKey.isValid('Pix@bcb.gov.br'), isFalse);
    expect(PixKey.isValid('11999999999'), isFalse);
  });

  test('cartão Luhn', () {
    expect(Cartao.isValid('4111111111111111'), isTrue);
    expect(Cartao.isValid('4111111111111112'), isFalse);
  });

  test('NF-e access key golden', () {
    expect(
      NfeChave.isValid('52060433009911002506550120000007800267301615'),
      isTrue,
    );
  });

  test('processo CNJ golden', () {
    expect(ProcessoCnj.isValid('0000100-34.2008.9.21.0000'), isTrue);
    expect(ProcessoCnj.isValid('00001003420089210000'), isTrue);
    expect(ProcessoCnj.isValid('0000100-00.2008.9.21.0000'), isFalse);
  });

  test('certidão mod 97', () {
    const body = '123456789012345678901234567890';
    final cert = body + iso7064Mod97CheckDigits(body);
    expect(Certidao.isValid(cert), isTrue);
    expect(Certidao.isValid('${body}00'), isFalse);
  });

  test('IBAN BR checksum', () {
    // ISO 13616 example (29 characters).
    const iban = 'BR1800360305000010009795493C1';
    expect(IbanBr.isValid(iban), isTrue);
    expect(IbanBr.isValid('BR18 00360305 00001 0009795493 C1'), isTrue);
    expect(IbanBr.isValid('BR00${iban.substring(4)}'), isFalse);
    expect(IbanBr.parse(iban).canonical.length, 29);
  });

  test('boleto cobrança round-trip', () {
    final linha = _cobrancaLinha();
    expect(Boleto.isValid(linha), isTrue);
    expect(Boleto.isValid(linha.replaceRange(32, 33, '0')), isFalse);
  });

  test('boleto arrecadação modulo 10 fields', () {
    final linha = _arrecadacaoLinha();
    expect(linha.length, 48);
    expect(Boleto.isValid(linha), isTrue);
    expect(Boleto.parse(linha).arrecadacao, isTrue);
    final wrong = ((int.parse(linha[11]) + 1) % 10).toString();
    expect(Boleto.isValid(linha.replaceRange(11, 12, wrong)), isFalse);
  });
}

String _completeCns(String fourteen) {
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    sum += (fourteen.codeUnitAt(i) - 48) * (15 - i);
  }
  final dv = (11 - (sum % 11)) % 11;
  return '$fourteen$dv';
}

String _cobrancaLinha() {
  final barcode = List<int>.filled(44, 0);
  barcode[0] = 0;
  barcode[1] = 0;
  barcode[2] = 1;
  barcode[3] = 9;
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
  var dv = 11 - (sum % 11);
  if (dv == 0 || dv == 10 || dv == 11) {
    dv = 1;
  }
  barcode[4] = dv;
  final bar = barcode.map((d) => d.toString()).join();
  final campo1 = bar.substring(0, 4) + bar.substring(19, 24);
  final campo2 = bar.substring(24, 34);
  final campo3 = bar.substring(34, 44);
  final campo5 = bar.substring(5, 19);
  String withDv(String field) {
    final d = modulo10FromRight(field.split('').map(int.parse).toList());
    return '$field$d';
  }

  return '${withDv(campo1)}${withDv(campo2)}${withDv(campo3)}${bar[4]}$campo5';
}

String _arrecadacaoLinha() {
  final data = List<int>.filled(44, 0);
  data[0] = 8;
  data[2] = 6;
  final buffer = StringBuffer();
  for (var block = 0; block < 4; block++) {
    final field = data.sublist(block * 11, block * 11 + 11).join();
    final dv = modulo10FromRight(field.split('').map(int.parse).toList());
    buffer.write(field);
    buffer.write(dv);
  }
  return buffer.toString();
}
