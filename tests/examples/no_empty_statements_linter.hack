//##! 1
namespace Linters\Tests\NoEmptyStatementsLinter;

;

//##! 15
function func1(?int $maybe_null): void {
  0 & 0;
  0 | 0;
  0 ^ 0;
  0 . 0;
  0 === 0;
  0 !== 0;
  0 >= 0;
  0 <= 0;
  0 - 0;
  0 % 0;
  0 + 0;
  $maybe_null ?? 0;
  0 / 0;
  0 * 0;
  0 ** 0;
}

//##! 0
function func2(): void {
  $x = 0;
  $x &= 0;
  $x |= 0;
  $x ^= 0;
  $x .= 0;
  $x = 0;
  $x >>= 0;
  $x <<= 0;
  $x -= 0;
  $x %= 0;
  $x += 0;
  $x ??= 0;
  $x /= 0;
  $x *= 0;
  $x **= 0;
}

//##! 0 Special case, empty is allowed for convenience
function func3(): void {
  0 |> 0;
}

//##! 1 Testing paren unwrapping.
function func4(): void {
  ((((((((((1))))) + ((((2)))))))));
}

//##! 0 Discarding the result explicitly is okay
function func5(): void {
  $_ = 1 + 1;
}
