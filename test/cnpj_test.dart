import 'dart:math';

import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  group('Cnpj', () {
    test('alphanumeric golden from SERPRO/RFB manual', () {
      const golden = '12.ABC.345/01DE-35';
      expect(Cnpj.isValid(golden), isTrue);
      expect(Cnpj.isValid('12ABC34501DE35'), isTrue);
      expect(Cnpj.isValid('12.abc.345/01de-35'), isTrue);
      final parsed = Cnpj.parse(golden);
      expect(parsed.canonical, '12ABC34501DE35');
      expect(parsed.formatted, golden);
      expect(parsed.base12, '12ABC34501DE');
      expect(Cnpj.checkDigitsFor('12ABC34501DE'), (3, 5));
    });

    test('numeric CNPJ still validates', () {
      expect(Cnpj.isValid('11.222.333/0001-81'), isTrue);
      expect(Cnpj.isValid('77287898000155'), isTrue);
    });

    test('rejects bad DV, length, unicode, all-same numeric', () {
      expect(Cnpj.isValid('12.ABC.345/01DE-00'), isFalse);
      expect(Cnpj.isValid('00000000000000'), isFalse);
      expect(Cnpj.isValid('12ABC34501DE3'), isFalse);
      expect(Cnpj.isValid('12.ABC.345/01DE-3A'), isFalse);
      expect(Cnpj.isValid('12ABC34501DE３５'), isFalse);
    });

    test('does not invent a letter blacklist', () {
      final digits = Cnpj.checkDigitsFor('ABCDEFGHIJKL');
      final candidate = 'ABCDEFGHIJKL${digits.$1}${digits.$2}';
      expect(Cnpj.isValid(candidate), isTrue);
    });

    test('uses calculated DV1 when checking DV2', () {
      expect(Cnpj.isValid('12ABC34501DE36'), isFalse);
    });
  });

  test('random valid bases round-trip; tampered DV fails', () {
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random(42);
    for (var i = 0; i < 200; i++) {
      final buffer = StringBuffer();
      for (var c = 0; c < 12; c++) {
        buffer.write(alphabet[random.nextInt(alphabet.length)]);
      }
      final base = buffer.toString();
      final dvs = Cnpj.checkDigitsFor(base);
      final canonical = '$base${dvs.$1}${dvs.$2}';
      expect(Cnpj.isValid(canonical), isTrue, reason: canonical);
      final bad = '$base${dvs.$1}${(dvs.$2 + 1) % 10}';
      if (bad != canonical) {
        expect(Cnpj.isValid(bad), isFalse, reason: bad);
      }
    }
  });
}
