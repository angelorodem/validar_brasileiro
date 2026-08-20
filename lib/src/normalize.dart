/// Shared input cleanup for Brazilian identifiers.
///
/// Mask characters (space, `+`, `.`, `/`, `-`, `(`, `)`) are skipped.
/// Everything else must be ASCII. This never strips letters — alphanumeric
/// CNPJ depends on that.
library;

const int _digit0 = 48;
const int _digit9 = 57;
const int _upperA = 65;
const int _upperZ = 90;
const int _lowerA = 97;
const int _lowerZ = 122;

/// Whether [codeUnit] is ASCII `0–9`.
bool isAsciiDigit(int codeUnit) => codeUnit >= _digit0 && codeUnit <= _digit9;

/// Whether [codeUnit] is ASCII `A–Z`.
bool isAsciiUpperLetter(int codeUnit) =>
    codeUnit >= _upperA && codeUnit <= _upperZ;

/// `ASCII(codeUnit) - 48` used by alphanumeric CNPJ (IN RFB 2.229/2024).
///
/// Digits map to `0–9`. `A` maps to `17`. `Z` maps to `42`.
int cnpjCharValue(int codeUnit) => codeUnit - _digit0;

/// Whether [codeUnit] is a formatting character that identifiers ignore.
///
/// Includes E.164 `+` so telephone / PIX keys such as `+55 11 99999-9999`
/// collect as digits. CNPJ still only treats `.`, `/`, `-`, and spaces as
/// separators in documentation; extra mask characters cannot introduce
/// letters or digits.
bool isMaskChar(int codeUnit) {
  return codeUnit == 32 ||
      codeUnit == 9 ||
      codeUnit == 43 || // +
      codeUnit == 46 || // .
      codeUnit == 47 || // /
      codeUnit == 45 || // -
      codeUnit == 40 || // (
      codeUnit == 41; // )
}

/// Collects ASCII digits, skipping mask characters.
///
/// Returns `null` when a non-mask, non-digit character is present.
String? collectDigits(String input) {
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final unit = input.codeUnitAt(i);
    if (isMaskChar(unit)) {
      continue;
    }
    if (!isAsciiDigit(unit)) {
      return null;
    }
    buffer.writeCharCode(unit);
  }
  return buffer.toString();
}

/// Collects ASCII letters and digits, skipping mask characters.
///
/// Letters are uppercased. Returns `null` on any other non-mask character.
String? collectAlphanumericUpper(String input) {
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final unit = input.codeUnitAt(i);
    if (isMaskChar(unit)) {
      continue;
    }
    if (isAsciiDigit(unit) || isAsciiUpperLetter(unit)) {
      buffer.writeCharCode(unit);
      continue;
    }
    if (unit >= _lowerA && unit <= _lowerZ) {
      buffer.writeCharCode(unit - 32);
      continue;
    }
    return null;
  }
  return buffer.toString();
}

/// Maps CNPJ base characters to their DV calculation values.
///
/// [canonical] must already be uppercase ASCII without mask.
List<int> cnpjCharValues(String canonical) {
  final values = List<int>.filled(canonical.length, 0);
  for (var i = 0; i < canonical.length; i++) {
    values[i] = cnpjCharValue(canonical.codeUnitAt(i));
  }
  return values;
}

/// Whether every character in [digits] is the same ASCII digit.
bool isRepeatedDigitString(String digits) {
  if (digits.isEmpty) {
    return false;
  }
  final first = digits.codeUnitAt(0);
  if (!isAsciiDigit(first)) {
    return false;
  }
  for (var i = 1; i < digits.length; i++) {
    if (digits.codeUnitAt(i) != first) {
      return false;
    }
  }
  return true;
}

/// Parses [canonical] as ASCII digits into a new list.
List<int> digitsOf(String canonical) {
  final digits = List<int>.filled(canonical.length, 0);
  for (var i = 0; i < canonical.length; i++) {
    digits[i] = canonical.codeUnitAt(i) - _digit0;
  }
  return digits;
}
