//##! 9
namespace Linters\Tests\KeywordsShouldBeLowercaseLinter;

function literals(): vec<mixed> {
  return vec[TRUE, True, tRuE, FALSE, False, fAlSe, NULL, Null, nUlL];
}

//##! 0

function canonical(): vec<mixed> {
  return vec[true, false, null];
}

//##! 0

final class Names {
  const string TRUE = 'TRUE';
  const string FALSE = 'FALSE';
  const string NULL = 'NULL';

  public function True(): void {}
  public function False(): void {}
  public function Null(): void {}
}

function names(Names $TRUE): vec<string> {
  $TRUE->True();
  $TRUE->False();
  $TRUE->Null();
  return vec[Names::TRUE, Names::FALSE, Names::NULL, "True False Null"];
}

//##! 3

function trivia(?bool $value = /* before */ NULL /* after */): bool {
  return $value ?? /* before */ TRUE /* after */ ? False : false;
}
