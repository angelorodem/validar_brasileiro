import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  const samples = ['12.ABC.345/01DE-35', '77287898000155', '12abc34501de35'];
  const iterations = 200000;
  final sw = Stopwatch()..start();
  var accepted = 0;
  for (var i = 0; i < iterations; i++) {
    if (Cnpj.isValid(samples[i % samples.length])) {
      accepted++;
    }
  }
  sw.stop();
  final perMs = iterations / sw.elapsedMicroseconds * 1000;
  // ignore: avoid_print
  print(
    'Cnpj.isValid $iterations times: ${sw.elapsedMilliseconds} ms '
    '(${perMs.toStringAsFixed(0)} /ms), accepted=$accepted',
  );
}
