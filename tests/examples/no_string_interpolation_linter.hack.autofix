//##! 5
namespace Linters\Tests\NoStringInterpolationLinter;

function func1(): void {
  $x = '';
  $d = dict['' => ''];

  "$x";

  "{$x}";

  "{$d['']}";

  $_ = <<<X
$x
X;

  $_ = <<<X
{$x}
X;
}

//##! 0

function func2(): void {
  $x = '';

  $_ = <<<'X'
$x
X;

  $_ = <<<'X'
{$x}
X;
}
