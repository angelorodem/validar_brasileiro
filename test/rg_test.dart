import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  test('SP checksum RG', () {
    expect(Rg.isValid('12.030.001-1', uf: Uf.sp), isTrue);
    expect(Rg.isValid('120300011', uf: Uf.sp), isTrue);
    expect(Rg.isValid('120300010', uf: Uf.sp), isFalse);
    expect(Rg.parse('120300011', uf: Uf.sp).checkKind, CheckKind.checksum);
  });

  test('RJ checksum RG', () {
    expect(Rg.isValid('2.799.811-1', uf: Uf.rj), isTrue);
    expect(Rg.isValid('27998110', uf: Uf.rj), isFalse);
  });

  test('MG uses checksum kind', () {
    expect(Rg.parse('27998111', uf: Uf.mg).checkKind, CheckKind.checksum);
    expect(Rg.isValid('27998110', uf: Uf.mg), isFalse);
  });

  test('other UFs are format-only and require UF', () {
    final rg = Rg.parse('12345678', uf: Uf.pr);
    expect(rg.checkKind, CheckKind.format);
    expect(Rg.isValid('12', uf: Uf.pr), isFalse);
  });
}
