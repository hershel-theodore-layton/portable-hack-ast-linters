//##! 0 not io
namespace Linters\Tests\ContextListMustBeExplicitOnIoFunctionsLinter;

function func1(): void {}

async function func2(): Awaitable<void> {}

final class C1 {
  public function func3(): void {
  }
}

//##! 0 has context list
function func4()[]: void {}

//##! 2 does io and doesn't have a context list
use namespace HH\Asio;

final class C2 {
  public async function func5(): Awaitable<void> {
    await Asio\later();
  }
}

async function func6(): Awaitable<void> {
  await Asio\later();
}
