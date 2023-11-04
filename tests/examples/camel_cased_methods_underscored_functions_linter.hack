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
