import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  final cpf = Cpf.parse('529.982.247-25');
  final parsedCnpj = Cnpj.parse('12.ABC.345/01DE-35');
  final message = all([required(), cnpj()])('12.ABC.345/01DE-35');

  // ignore: avoid_print
  print('CPF ${cpf.formatted} check=${Cpf.checkKind.name}');
  // ignore: avoid_print
  print('CNPJ ${parsedCnpj.formatted} base=${parsedCnpj.base12}');
  // ignore: avoid_print
  print('form ok: ${message == null}');
}
