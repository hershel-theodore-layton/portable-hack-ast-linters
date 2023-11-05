//##! 0 Setup
namespace Linters\Tests\DontCreateForwardingLambdasLinter;

function example(mixed ...$args): void {}
function example_inout(inout mixed $arg, mixed ...$args): void {}
async function example_async(mixed ...$args): Awaitable<void> {}

//##! 11 All forwarding

function func1(): void {
  $_ = () ==> example();
  $_ = $s ==> example($s);
  $_ = ($s) ==> example($s);
  $_ = (...$xs) ==> example(...$xs);
  $_ = ($x, ...$xs) ==> example($x, ...$xs);
  $_ = (inout $x, ...$xs) ==> example_inout(inout $x, ...$xs);

  $_ = async () ==> await example_async();
  $_ = async $s ==> await example_async($s);
  $_ = async ($s) ==> await example_async($s);
  $_ = async (...$xs) ==> await example_async(...$xs);
  $_ = async ($x, ...$xs) ==> await example_async($x, ...$xs);
  // async inout is illegal Hack example_inout_async(...);
}

//##! 0 All okay

function func2(): void {
  $_ = ($s) ==> example(...$s);
  $_ = (...$xs) ==> example($xs);
  $_ = ($a, $b) ==> example($b, $a);

  $_ = async ($s) ==> example(...$s);

  $_ = (nothing $a) ==> example($a->hi());
}


//##! 0 Special rules for parent and self, since it is not always valid to
//      form a function reference to them. parent::m1<> is never allowed,
//      whereas self::m1<> is only allowed in final classes.
//      The lint doesn't bother checking for finality, so both lint clean.

abstract class X {
  public static function m1(): void {}
}

final class Y extends X {
  public static function m1(): void {
    $_ = () ==> parent::m1();
    $_ = () ==> self::m1();
  }
}
