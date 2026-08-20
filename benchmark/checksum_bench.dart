import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  const cpfSamples = ['529.982.247-25', '123.456.789-09', '52998224725'];
  const cnpjSamples = [
    '12.ABC.345/01DE-35',
    '77287898000155',
    '12abc34501de35',
  ];
  const pisSamples = ['100.27230.88-8', '10027230888', '00000000000'];
  const iterations = 100000;

  _run('Cpf.isValid', cpfSamples, Cpf.isValid, iterations);
  _run('Cnpj.isValid', cnpjSamples, Cnpj.isValid, iterations);
  _run('Pis.isValid', pisSamples, Pis.isValid, iterations);
}

void _run(
  String label,
  List<String> samples,
  bool Function(String) check,
  int iterations,
) {
  final sw = Stopwatch()..start();
  var accepted = 0;
  for (var i = 0; i < iterations; i++) {
    if (check(samples[i % samples.length])) {
      accepted++;
    }
  }
  sw.stop();
  final perMs = iterations / sw.elapsedMicroseconds * 1000;
  // ignore: avoid_print
  print(
    '$label $iterations times: ${sw.elapsedMilliseconds} ms '
    '(${perMs.toStringAsFixed(0)} /ms), accepted=$accepted',
  );
}
