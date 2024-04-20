//##! 0
namespace Linters\Tests\AsyncFunctionAndMethodLinter;

function func1(): void {}

async function func1_async(): Awaitable<void> {}

function func2_async(): Awaitable<void> {
  return async {
  };
}

async function func3_asyncx(): Awaitable<void> {}

//##! 1 missing _async suffix
async function func2(): Awaitable<void> {}

//##! 1 missing _async suffix
function func3(): Awaitable<void> {
  return async {
  };
}

//##! 0
final class X1 {
  public function func(): void {}
}

final class X2 {
  public async function funcAsync(): Awaitable<void> {}
}

final class X3 {
  public async function funcAsyncx(): Awaitable<void> {}
}

//##! 1 missing Async suffix
final class X4 {
  public async function func(): Awaitable<void> {}
}

//##! 1 missing Async suffix
final class X5 {
  public function func(): Awaitable<void> {
    return async {
    };
  }
}

//##! 0
final class X6 {
  public function func_UNTYPED(): void {}
}

final class X7 {
  public async function funcAsync_DO_NOT_USE(): Awaitable<void> {}
}

final class X8 {
  public async function funcAsyncx_DEPRECATED(): Awaitable<void> {}
}

final class X9 {
  public async function funcAsyncx_UNSAFE(): Awaitable<void> {}
}
