# validar_brasileiro

Brazilian document and form validators for **Dart and Flutter**.

`isValid` / `tryParse` mean the value is **well-formed** and passes a published checksum or format table. They do **not** mean a government registry issued it.

This package is a from-scratch alternative to [`validadores`](https://pub.dev/packages/validadores), with alphanumeric CNPJ (IN RFB 2.229/2024) and a typed API. It does not clone that package’s fluent `Validador`.

## Check catalog

| Type | Kind | Notes |
|------|------|--------|
| CPF | checksum | Modulo 11 |
| CNPJ | checksum | Numeric + alphanumeric, `ASCII-48` |
| PIS/PASEP/NIS/NIT | checksum | NIT modulo 11 |
| CNH | checksum | Modulo 11 + desconto |
| RENAVAM | checksum | Modulo 11 |
| Título de eleitor | checksum | UF `01–28`, SP/MG remainder rule |
| CNS | checksum | Definitive `1\|2`, provisional `7\|8\|9` |
| Inscrição Estadual | checksum | All 27 UFs + SP rural `P` |
| RG | checksum or format | Checksum SP/RJ/MG; other UFs format-only, **UF required** |
| Chave NF-e | checksum | 44 digits, models 55/65 |
| Boleto | checksum | Cobrança 44/47, arrecadação 48 |
| Processo CNJ | checksum | ISO 7064 mod 97-10 |
| Certidão civil | checksum | 32 digits, mod 97 |
| IBAN BR | checksum | ISO 13616 |
| Cartão | checksum | Luhn |
| CEP | format | 8 digits, no Correios lookup |
| Telefone | format | 67 DDDs, Anatel shape |
| Placa | format | Legacy + Mercosul |
| PIX | format | CPF/CNPJ/email/phone/UUID syntax |
| E-mail | format | Form-grade, including `.br` |

Not in this package: Receita/Correios/SENATRAN lookups, alphanumeric CPF (no official spec yet), CNAE/NCM dumps, CRM/OAB.

## Install

```yaml
dependencies:
  validar_brasileiro: ^0.1.0
```

## Usage

```dart
import 'package:validar_brasileiro/validar_brasileiro.dart';

final cnpj = Cnpj.parse('12.ABC.345/01DE-35');
Cpf.isValid('529.982.247-25'); // true

// TextFormField-style: null = ok, otherwise a plain message
final validator = all([
  required(),
  cnpj(message: 'CNPJ inválido'),
]);
```

## Local development

```bash
dart pub get
dart format .
dart analyze --fatal-infos
dart test
```

Pure Dart — Flutter apps can depend on this package without a plugin.

## License

MIT
