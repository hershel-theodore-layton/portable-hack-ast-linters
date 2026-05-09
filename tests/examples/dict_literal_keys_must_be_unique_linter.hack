//##! 0 Valid initializers
namespace Linters\Tests\DictLiteralKeysMustBeUniqueLinter;

function func1(): void {
  $_ = dict[];
  $_ = dict[1 => 1, 2 => 2];
}

//##! 2 Invalid initializers

function func2(): void {
  $_ = dict[
    1 => 1,
    1 => 2,
  ];

  $_ = dict[
    'a' => 1,
    'b' => 2,
    'a' => 3,
  ];
}

//##! 2 One dict can raise multiple errors

function func3(): void {
  $_ = dict[
    'a' => 1,
    'b' => 2,
    'a' => 3,
    'b' => 4,
  ];
}

//##! 2 One dict can raise multiple errors for the same key

function func4(): void {
  $_ = dict[
    'a' => 1,
    'b' => 2,
    'a' => 3,
    'a' => 4,
  ];
}

//##! 1 False positive, this linter assumes that the same textual expression
//      will result in the same value, even if the expression could be impure.

use namespace HH\Lib\PseudoRandom;

function func5(): void {
  $_ = dict[
    PseudoRandom\int() => 1,
    PseudoRandom\int() => 2,
  ];
}

//##! 0 False negative, this linter does not evaluate the keys.

function func6(): void {
  $_ = dict[
    'a'.'a' => 1,
    'aa' => 2,
  ];
}

//##! 1 This linter understands that comments do not affect the value

function func7(): void {
  $_ = dict[
    /**/'a'/**/ => 1,
    // single-line
    'a' => 2,
  ];
}
