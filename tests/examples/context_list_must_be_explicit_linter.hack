//##! 3
namespace Linters\Tests\ContextListMustBeExplicitLinter;

function func1(): void {}

final class C1 {
  public function func2((function(): int) $func3): void {
    $func3();
  }
}

//##! 0
function func4()[]: void {}

final class C2 {
  public function func5((function()[_]: int) $func6)[ctx $func6]: void {
    $func6();
  }
}
