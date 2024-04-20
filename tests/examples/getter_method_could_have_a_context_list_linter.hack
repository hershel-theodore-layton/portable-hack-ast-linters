//##! 3 Getters in three flavors.
namespace Linters\Tests\GetterMethodCanBeMadePureLinter;

final class C1 {
  private int $it = 42;
  private bool $that = false;

  public function getIt(): int {
    return $this->it;
  }

  public function isIt(): bool {
    return $this->that;
  }

  public function hasIt(): bool {
    return $this->that;
  }
}

//##! 0 Adding explicit contexts (not just `[]`) supresses the lint error

final class C2 {
  private int $it = 42;
  private bool $that = false;

  public function getIt()[]: int {
    return $this->it;
  }

  public function isIt()[write_props]: bool {
    return $this->that;
  }

  public function hasIt()[defaults]: bool {
    return $this->that;
  }
}

//##! 2 Simple type assertions

final class C3 {
  private ?C1 $c;

  public function getC(): C1 {
    return $this->c as nonnull;
  }

  public function getNonCanonical(): C1 {
    return $this->c as C1;
  }
}

//##! 0 False negative, type assertion with generic

final class C4 {
  private ?vec<int> $vec;

  public function getThem(): vec<int> {
    return $this->vec as vec<_>;
  }
}

//##! 0 Interfaces and abstract methods are not checked

interface I1 {
  public function getIt(): int;
}

abstract class C5 {
  abstract public function getIt(): int;
}

//##! 0 Are they simple getters as an implementation detail
//      or are they simple getters in disguise, who knows?

final class C6 {
  private int $speed = 5;
  private ?C6 $parent;

  public function isFast(): bool {
    return $this->speed > 10;
  }

  public function isRoot(): bool {
    return $this->parent === null;
  }
}

//##! 1 But if you write it as a typecheck, this is a strong indication
//    that it is a simple getter in the
//    `getB(): ?B` `hasB(): bool`, `getBx(): B` style.

final class C7 {
  private ?C7 $parent;

  public function isRoot(): bool {
    return $this->parent is null;
  }
}
