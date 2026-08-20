import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  test('CNPJ base maps ASCII minus 48', () {
    expect(cnpjCharValues('12ABC34501DE'), [
      1,
      2,
      17,
      18,
      19,
      3,
      4,
      5,
      0,
      1,
      20,
      21,
    ]);
    expect(cnpjCharValue('A'.codeUnitAt(0)), 17);
    expect(cnpjCharValue('Z'.codeUnitAt(0)), 42);
    expect(cnpjCharValue('0'.codeUnitAt(0)), 0);
  });

  test('collectAlphanumericUpper skips mask and uppercases', () {
    expect(collectAlphanumericUpper('12.abc.345/01de-35'), '12ABC34501DE35');
    expect(collectAlphanumericUpper('12*ABC'), isNull);
  });

  test('collectDigits skips E.164 plus and phone mask', () {
    expect(Phone.isValid('+55 11 3333-3333'), isTrue);
    expect(Phone.isValid('+55 (11) 99999-9999'), isTrue);
  });
}
