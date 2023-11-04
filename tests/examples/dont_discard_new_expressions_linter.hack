//##! 1 Classic error, an unthrown exception
namespace Linters\Tests\DontDiscardNewExpressionsLinter;

function func1(): void {
  new \Exception();
}

//##! 0

function func2(mixed ...$args): void {
  $_ = new \Exception();
  func2(new \Exception());
  (new \Exception())->toString();
}