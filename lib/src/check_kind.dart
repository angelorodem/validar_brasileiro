/// How a value is checked by this package.
///
/// None of these prove that a government registry issued the value.
enum CheckKind {
  /// Digits or letters plus a published check-digit algorithm.
  checksum,

  /// Shape, charset, and/or an official table (DDD, plate mask, CEP length).
  format,
}
