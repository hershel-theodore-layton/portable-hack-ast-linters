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

//##! 1 The inner RHS uses only the inner pipe value.
function func3(): void {
  $a = 0 |> (0 |> $$);
}

//##! 0
function func4(): void {
  $a = 0 |> $$;
}

//##! 0 The inner left operand reads the outer value.
function func5(): void {
  $a = 1 |> ($$ + 2 |> $$ + 3);
}

//##! 1 Only the inner pipe discards its value.
function func6(): void {
  $a = 1 |> ($$ |> 2);
}

//##! 0 Left-associated stages each consume the previous value.
function func7(): void {
  $a = 1 |> $$ + 2 |> $$ + 3;
}

//##! 2 Both pipes discard their value.
function func8(): void {
  $a = 1 |> (2 |> 3);
}

//##! 1 A read in an ordinary binary expression still counts.
function func9(): void {
  $a = 1 |> ($$ + (2 |> 3));
}
