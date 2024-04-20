//##! 1
namespace Linters\Tests\UnusedPipeVariableLinter;

function func1(): void {
  $a = 0 |> 0;
}

//##! 1
function func2(): void {
  $a = 0;
  $b = $a |> $a;
}

//##! 0 False negative, the $$ is on the RHS of the inner |>, but the outer
//      should have a lint error.
function func3(): void {
  $a = 0 |> (0 |> $$);
}

//##! 0
function func4(): void {
  $a = 0 |> $$;
}
