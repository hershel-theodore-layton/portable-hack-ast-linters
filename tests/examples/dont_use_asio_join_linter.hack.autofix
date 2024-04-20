//##! 1 Fully qualified
namespace Linters\Tests\DontUseAsioJoinLinter;

function func1(): void {
  \HH\Asio\join(async {
  });
}

//##! 2 Namespace used
use namespace HH\Asio;
use namespace HH\Asio as NotAsio;

function func2(): void {
  Asio\join(async {
  });
  NotAsio\join(async {
  });
}

//##! 4 Function used (both use clauses and both invocations)
use function HH\Asio\join;
use function HH\Asio\join as not_join;

function func3(): void {
  join(async {
  });
  not_join(async {
  });
}

//##! 0 A different join
use namespace HH\Lib\Str;

function func4(): void {
  Str\join(vec[], '');
}

//##! 1 You can't outsmart this linter with levels of indirection.
function func5(): void {
  $join = \HH\Asio\join<>;
  $join(async {
  });
}
