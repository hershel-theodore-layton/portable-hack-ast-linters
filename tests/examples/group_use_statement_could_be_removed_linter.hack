//##! 5 All import kinds
namespace Linters\Tests\EmptyGroup0 {
  use namespace Foo\Bar\{};
  use type Foo\Bar\{};
  use function Foo\Bar\{};
  use const Foo\Bar\{};
  use Foo\Bar\{};
}
//##! 1 Leading backslash
namespace Linters\Tests\EmptyGroup1 {
  use type \Foo\Bar\{};
}
//##! 2 Whitespace and comments do not add clauses
namespace Linters\Tests\EmptyGroup2 {
  use type Foo\Bar\{};
  use namespace Foo\Bar\{/* empty */};
}
//##! 1 Preserve surrounding comments
namespace Linters\Tests\EmptyGroup3 {
  // Before the import
  use type Foo\Bar\{}; // After the import
  use type Foo\Bar\Baz;
}
//##! 0 Nonempty groups and direct imports
namespace Linters\Tests\EmptyGroup4 {
  use type Foo\Bar\{Baz};
  use type Foo\Bar\{Qux};
  use function Foo\Bar\{one, two};
  use namespace Foo\Bar\Sub;
  use Foo\Bar\{const VALUE};
}
//##! 1 Namespace block
namespace Linters\Tests\EmptyGroupBlock {
  use type Foo\Bar\{};
  use type Foo\Bar\Baz;
}
