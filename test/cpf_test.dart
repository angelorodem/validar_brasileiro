import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  group('Cpf', () {
    test('accepts masked and unmasked valid numbers', () {
      expect(Cpf.isValid('529.982.247-25'), isTrue);
      expect(Cpf.parse('52998224725').formatted, '529.982.247-25');
      expect(Cpf.isValid('123.456.789-09'), isTrue);
    });

    test('rejects repeated digits, bad DV, short, letters, unicode', () {
      expect(Cpf.isValid('00000000000'), isFalse);
      expect(Cpf.isValid('111.111.111-11'), isFalse);
      expect(Cpf.isValid('529.982.247-24'), isFalse);
      expect(Cpf.isValid('529982247'), isFalse);
      expect(Cpf.isValid(''), isFalse);
      expect(Cpf.isValid('5299822472A'), isFalse);
      expect(Cpf.isValid('５２９９８２２４７２５'), isFalse);
    });

    test('parse throws FormatException', () {
      expect(() => Cpf.parse('x'), throwsFormatException);
    });
  });
}
