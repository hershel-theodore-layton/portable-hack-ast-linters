//##! 1
namespace Linters\Tests\NoFinalMethodsInFinalClassesLinter;

final class X1 {
  final public function func1(): void {}
}

//##! 0

final class X2 {
  public function func1(): void {}
}

class X3 {
  final public function func1(): void {}
}
