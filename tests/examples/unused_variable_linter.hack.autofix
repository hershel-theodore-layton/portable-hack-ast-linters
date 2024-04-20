//##! 1
namespace Linters\Tests\UnusedVariableLinter;

function example(mixed ...$args): void {}

//##! 2 Only ever assigned

function func1(): void {
  $b = 0;
  $b += 1;
}

//##! 1 Shadowing in lambda

function func2(): void {
  $a = '';

  $_ = () ==> {
    $a = 3;
  };

  example($a);
}

//##! 0 False negative

function func3(): void {
  $a = '';

  $_ = async {
    $a = 3;
  };

  example($a);
}


//##! 1 Shadowing lambda parameter

function func4(): void {
  $a = '';

  $_ = $a ==> $a;
}

//##! 1 Constructor property promotion

class X1 {
  public function __construct(public int $used, int $unused) {}
}

//##! 0 Abstract method arguments don't count

abstract class X2 {
  abstract public function func1(int $abstract): void;
}

interface X3 {
  public function func1(int $abstract): void;
}

//##! 0 Assignment only, but in a reference lvalue position.

function func5(): void {
  $x = new X1(1, 1);
  // We can't determine if the `value` is uniquely owned by func5.
  // `$x` is owned by func5, but the object may be observed elsewhere.
  // For this reason, we can't mark `$x` as unused,
  // since this assignment may produce a non-local effect.
  $x->used = 4;
}

//##! 0 Variables inside list(...) are assigned in top-level positions.

function func6(): void {
  $a = vec[];
  $b = 1;
  // This test is a little contrived, this proves $b is not unused.
  list($a[$b]) = $a;
}

//##! 1 inout parameters are used in write-only positions

function func7(inout vec<int> $items, inout vec<int> $unused): void {
  $items[] = 2;
  $_ = (inout vec<int> $counter) ==> {
    $counter[] = 2;
  };
}

//##! 5 Pre and post increment are not expressions in hhvm 4.38 and above
//      For this reason, we can treat them as assignments (not as a use).

function func8(int $unused, inout int $used): void {
  ++$unused;
  $unused++;
  --$unused;
  $unused--;

  ++$used;
  $used++;
  --$used;
  $used++;
}
