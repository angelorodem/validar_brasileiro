/// Shared check-digit primitives. Document types call these; they do not
/// reimplement the loops.
library;

import 'normalize.dart';

/// Weighted sum of [values] by [weights]. Lengths must match.
int weightedSum(List<int> values, List<int> weights) {
  var sum = 0;
  for (var i = 0; i < values.length; i++) {
    sum += values[i] * weights[i];
  }
  return sum;
}

/// CPF/CNPJ-style modulo 11: remainder `0` or `1` yields `0`, else `11 - r`.
int modulo11CpfStyle(int sum) {
  final remainder = sum % 11;
  if (remainder < 2) {
    return 0;
  }
  return 11 - remainder;
}

/// Modulo 11 walking from the right with weights `2…9` repeating.
int modulo11FromRight(List<int> body) {
  var weight = 2;
  var sum = 0;
  for (var i = body.length - 1; i >= 0; i--) {
    sum += body[i] * weight;
    weight++;
    if (weight > 9) {
      weight = 2;
    }
  }
  return modulo11CpfStyle(sum);
}

/// Modulo 10 from the right with weights `2,1,2,1…` (boleto field DV).
///
/// Products greater than 9 contribute the sum of their decimal digits.
int modulo10FromRight(List<int> body) {
  var weight = 2;
  var sum = 0;
  for (var i = body.length - 1; i >= 0; i--) {
    var product = body[i] * weight;
    if (product > 9) {
      product = (product ~/ 10) + (product % 10);
    }
    sum += product;
    weight = weight == 2 ? 1 : 2;
  }
  final remainder = sum % 10;
  if (remainder == 0) {
    return 0;
  }
  return 10 - remainder;
}

/// Running ISO 7064 modulo 97 over ASCII digits (chunked, no BigInt).
int runningMod97(String digits) {
  var remainder = 0;
  for (var i = 0; i < digits.length; i++) {
    remainder = (remainder * 10 + (digits.codeUnitAt(i) - 48)) % 97;
  }
  return remainder;
}

/// ISO 7064 mod 97-10: a complete digit string is valid when remainder is `1`.
bool iso7064Mod97IsValid(String digits) => runningMod97(digits) == 1;

/// Check digits `00–97` such that [body] plus those digits is mod-97 valid.
String iso7064Mod97CheckDigits(String body) {
  final remainder = runningMod97('${body}00');
  final check = 98 - remainder;
  if (check < 10) {
    return '0$check';
  }
  return '$check';
}

/// Luhn (ISO/IEC 7812) over ASCII digit characters.
bool luhnIsValid(String digits) {
  var sum = 0;
  var doubleDigit = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var value = digits.codeUnitAt(i) - 48;
    if (doubleDigit) {
      value *= 2;
      if (value > 9) {
        value -= 9;
      }
    }
    sum += value;
    doubleDigit = !doubleDigit;
  }
  return sum % 10 == 0;
}

/// IBAN rearranging: move the first four characters to the end, map A–Z to
/// `10–35`, then require mod 97 == 1.
bool ibanMod97IsValid(String canonicalUpper) {
  if (canonicalUpper.length < 5) {
    return false;
  }
  final rearranged =
      canonicalUpper.substring(4) + canonicalUpper.substring(0, 4);
  var remainder = 0;
  for (var i = 0; i < rearranged.length; i++) {
    final unit = rearranged.codeUnitAt(i);
    if (isAsciiDigit(unit)) {
      remainder = (remainder * 10 + (unit - 48)) % 97;
    } else if (isAsciiUpperLetter(unit)) {
      final mapped = unit - 55; // A → 10
      remainder = (remainder * 100 + mapped) % 97;
    } else {
      return false;
    }
  }
  return remainder == 1;
}
