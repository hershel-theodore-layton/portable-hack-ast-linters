//##! 2
namespace Linters\Tests\LambdaParameterListParenthesesCanBeRemovedLinter;

use namespace HH\Asio;

function f1(): void {
  $_ = ($a) ==> $a;
  $_ = async ($b) ==> {
    await Asio\usleep($b);
    return $b;
  };
}

//##! 0
use namespace HH;

final class Attr implements HH\ParameterAttribute, HH\LambdaAttribute {}

<<__EntryPoint>>
function f2(): void {
  $_ = ($a): int ==> $a;
  $_ = ($a)[] ==> $a;
  $_ = ($a, $b) ==> $a + $b;

  $_ = (int $a) ==> $a;
  $_ = (readonly int $a) ==> +HH\Readonly\as_mut($a);
  $_ = (inout int $a) ==> $a;
  $_ = ($a = 5) ==> $a;
  $_ = (...$a) ==> $a;
  $_ = (<<Attr>> $a) ==> $a;
  $_ = <<Attr>> $a ==> $a;
  //   ^^^^^^^^ This attribute applies to the lambda, not to the argument.
  //            That is why removing the parentheses from `<<Attr>> ($a) ==> $a`
  //            would retain the exact same meaning.
}
