# validar_brasileiro

Brazilian document and form validators for **Dart and Flutter**.

This package is a from-scratch alternative to [`validadores`](https://pub.dev/packages/validadores), with extra coverage such as **alphanumeric CNPJ** (IN RFB 2.229/2024) and a strong test suite.

The public API is being added next. The repository layout, analyzer rules, CI, and pub.dev metadata are already in place.

## Status

`0.0.1` is a publishable scaffold, not a complete validator set yet.

Planned:

- CPF
- CNPJ (numeric and alphanumeric)
- Other PT-BR form checks used by ChargeApp (email, required, length, and related rules)
- High-coverage unit tests

## Install (after the first pub.dev release)

```yaml
dependencies:
  validar_brasileiro: ^0.0.1
```

Until then, depend on git:

```yaml
dependencies:
  validar_brasileiro:
    git:
      url: https://github.com/angelorodem/validar_brasileiro.git
```

## Local development

```bash
dart pub get
dart format .
dart analyze --fatal-infos
dart test
```

This is a **pure Dart** package. Flutter apps can depend on it without pulling a Flutter plugin.

## License

MIT
