import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  group('email', () {
    test('accepts .br and .com.br', () {
      expect(EmailAddress.isValid('contato@registro.br'), isTrue);
      expect(EmailAddress.isValid('contato@365apps.com.br'), isTrue);
      expect(EmailAddress.isValid('marcelo.tobbias@gmail.com'), isTrue);
    });

    test('rejects incomplete and empty', () {
      expect(EmailAddress.isValid('marcelo.tobbias@gmail'), isFalse);
      expect(EmailAddress.isValid(''), isFalse);
      expect(EmailAddress.isValid('a@b'), isFalse);
      expect(EmailAddress.isValid('not an email'), isFalse);
    });
  });

  group('form rules', () {
    test('required and requiredWhen', () {
      expect(required()(null), 'Campo obrigatório');
      expect(required()(' x '), isNull);
      expect(requiredWhen(false)(null), isNull);
      expect(requiredWhen(true)(''), 'Campo obrigatório');
    });

    test('equals, length, numeric range', () {
      expect(equalsTo('abc')('abc'), isNull);
      expect(equalsTo('abc')('ab'), isNotNull);
      expect(minLength(3)('ab'), isNotNull);
      expect(minLength(3)('abc'), isNull);
      expect(maxLength(2)('abc'), isNotNull);
      expect(minValue(10)('9'), isNotNull);
      expect(minValue(10)('10'), isNull);
      expect(maxValue(10)('11'), isNotNull);
      expect(minValue(1)('x'), isNotNull);
    });

    test('all returns the first message, not a list dump', () {
      final validator = all([required(message: 'req'), cpf(message: 'cpf')]);
      expect(validator(null), 'req');
      expect(validator('123'), 'cpf');
      expect(validator('529.982.247-25'), isNull);
      expect(validator('123')!.startsWith('['), isFalse);
    });
  });
}
