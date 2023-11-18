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

//##! 2 Function used
use function HH\Asio\join;
use function HH\Asio\join as not_join;

function func3(): void {
  join(async {
  });
  not_join(async {
  });
}
