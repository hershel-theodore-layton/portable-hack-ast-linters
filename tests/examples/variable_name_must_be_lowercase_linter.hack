//##! 0 Valid uses of $camelCase variables
namespace Linters\Tests\VariableNameMustBeLowercaseLinter;

final class C1 {
  private null $varOne;
  private null $varTwo, $varThree;
  private static null $varFour;
  private static null $varFive, $varSix;

  private function __construct(private null $varSeven) {
    \var_dump($varSeven, $this->varSeven, static::$varFive);
  }
}

//##! 4 All local variables, with the exception of promoted parameters must be $snake_case
final class C2 {
  private function __construct(nothing $varOne) {
    $varOne::$static_prop;
    $varTwo = 2;

    foreach (vec[] as $varThree) {
    }
  }
}
