import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  test('rejects empty, null-like, and unicode digits', () {
    expect(Cpf.isValid(''), isFalse);
    expect(Cnpj.isValid(''), isFalse);
    expect(Cpf.tryParse(' '), isNull);
    expect(Cpf.isValid('52998224725\u0000'), isFalse);
    expect(Pis.isValid(''), isFalse);
    expect(Cnh.isValid(''), isFalse);
    expect(Cep.isValid(''), isFalse);
    expect(Phone.isValid(''), isFalse);
    expect(Placa.isValid(''), isFalse);
    expect(PixKey.isValid(''), isFalse);
    expect(IbanBr.isValid(''), isFalse);
    expect(Cpf.isValid('５２９９８２２４７２５'), isFalse);
    expect(Cnpj.isValid('12ABC34501DE３５'), isFalse);
    expect(Cep.isValid('01310-10０'), isFalse);
  });

  test('form validators never return list toString', () {
    for (final message in [
      cnpj()('not-a-cnpj'),
      cpf()('x'),
      pis()('x'),
      cnh()('x'),
      pix()('x'),
      boleto()('x'),
      ie(Uf.sp)('x'),
      rg(Uf.sp)('x'),
    ]) {
      expect(message, isNotNull);
      expect(message!.contains('['), isFalse);
    }
  });
}
