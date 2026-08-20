import 'package:test/test.dart';
import 'package:validar_brasileiro/validar_brasileiro.dart';

void main() {
  const goldens = <Uf, String>{
    Uf.ac: '0113253877910',
    Uf.al: '248682954',
    Uf.am: '917050150',
    Uf.ap: '039045820',
    Uf.ba: '63984300',
    Uf.ce: '836182316',
    Uf.df: '0730000100109',
    Uf.es: '463921810',
    Uf.go: '112237118',
    Uf.ma: '123517680',
    Uf.mg: '2490944173923',
    Uf.ms: '282570926',
    Uf.mt: '130000019',
    Uf.pa: '153662476',
    Uf.pb: '312029063',
    Uf.pe: '064970639',
    Uf.pi: '465180426',
    Uf.pr: '0031595584',
    Uf.rj: '06540481',
    Uf.rn: '204502292',
    Uf.ro: '39206839474860',
    Uf.rr: '247681047',
    Uf.rs: '3288345503',
    Uf.sc: '632480718',
    Uf.se: '826594042',
    Uf.sp: '110042490114',
    Uf.to: '27035910938',
  };

  test('SINTEGRA goldens per UF', () {
    goldens.forEach((uf, ie) {
      expect(Ie.isValid(ie, uf: uf), isTrue, reason: '$uf $ie');
    });
  });

  test('SP rural producer', () {
    expect(Ie.isValid('P-01100424.3/002', uf: Uf.sp), isTrue);
    expect(Ie.parse('P011004243002', uf: Uf.sp).produtorRural, isTrue);
  });

  test('wrong UF fails', () {
    expect(Ie.isValid('110042490114', uf: Uf.rj), isFalse);
    expect(Ie.isValid('', uf: Uf.sp), isFalse);
    expect(Ie.isValid('11004249011４', uf: Uf.sp), isFalse);
  });
}
