//##! 0
namespace Linters\Tests\CamelCasedMethodsUnderscoredFunctionsLinter;
function func_name1(): void {}

final class X1 {
  public function funcName(): void {}
}

//##! 1 snake cased method
final class X2 {
  public function func_name(): void {}
}

//##! 1 camel cased function
function funcName(): void {}

//##! 0 factory functions

final class Factory {
  public function Factory(): Factory {
    return new Factory();
  }
}

final class GenericFactory<T> {}

function GenericFactory(): GenericFactory<int> {
  return new GenericFactory();
}

//##! 0 special cased suffixes

final class X3 {
  public function __construct()[] {}
  public function a_DEPRECATED(): void {}
  public function a_DO_NOT_USE(): void {}
  public function a_UNSAFE(): void {}
  public function a_UNTYPED(): void {}
}

function a_DEPRECATED(): void {}
function a_DO_NOT_USE(): void {}
function a_UNSAFE(): void {}
function a_UNTYPED(): void {}

//##! 0 suffix with double underscore in method

final class X4 {
  public function a__DO_NOT_USE(): void {}
}

//##! 0 allow methods that start with `test_` or `provide_`. I prefer test
//    class methods to be written in snake case.

abstract class TestFramework {}
final class ProviderOfData implements \HH\MethodAttribute {
  public function __construct(private string $methodName) {}
}

final class X5Test {
  public function provide_bobbles(): vec<(int, int)> {
    return vec[tuple(1, 2)];
  }

  <<ProviderOfData('provide_bobbles')>>
  public function test_the_bobble(int $bob, int $ble): void {
    invariant($bob * 2 === $ble, 'Test failed');
  }

  <<ProviderOfData('provide_bobbles')>>
  public async function test_the_bobble_async(
    int $bob,
    int $ble,
  ): Awaitable<void> {
    await \HH\Asio\later();
    invariant($bob * 2 === $ble, 'Test failed');
  }
}
