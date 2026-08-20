/// Brazilian federative unit (26 states + DF).
enum Uf {
  /// Acre.
  ac('AC'),

  /// Alagoas.
  al('AL'),

  /// Amazonas.
  am('AM'),

  /// Amapá.
  ap('AP'),

  /// Bahia.
  ba('BA'),

  /// Ceará.
  ce('CE'),

  /// Distrito Federal.
  df('DF'),

  /// Espírito Santo.
  es('ES'),

  /// Goiás.
  go('GO'),

  /// Maranhão.
  ma('MA'),

  /// Minas Gerais.
  mg('MG'),

  /// Mato Grosso do Sul.
  ms('MS'),

  /// Mato Grosso.
  mt('MT'),

  /// Pará.
  pa('PA'),

  /// Paraíba.
  pb('PB'),

  /// Pernambuco.
  pe('PE'),

  /// Piauí.
  pi('PI'),

  /// Paraná.
  pr('PR'),

  /// Rio de Janeiro.
  rj('RJ'),

  /// Rio Grande do Norte.
  rn('RN'),

  /// Rondônia.
  ro('RO'),

  /// Roraima.
  rr('RR'),

  /// Rio Grande do Sul.
  rs('RS'),

  /// Santa Catarina.
  sc('SC'),

  /// Sergipe.
  se('SE'),

  /// São Paulo.
  sp('SP'),

  /// Tocantins.
  to('TO');

  const Uf(this.code);

  /// Two-letter IBGE/postal code.
  final String code;

  /// Parses a two-letter code such as `SP` (case-insensitive).
  static Uf? tryParse(String input) {
    final trimmed = input.trim().toUpperCase();
    for (final uf in Uf.values) {
      if (uf.code == trimmed) {
        return uf;
      }
    }
    return null;
  }
}
