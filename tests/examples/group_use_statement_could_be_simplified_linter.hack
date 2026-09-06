//##! 5 All import kinds
namespace Linters\Tests\SingleGroup0 {
  use namespace Foo\Bar\{Baz};
  use type Foo\Bar\{Qux};
  use function Foo\Bar\{func};
  use const Foo\Bar\{VALUE};
  use Foo\Bar\{Other};
}
//##! 2 Aliases, qualified clauses, and leading backslashes
namespace Linters\Tests\SingleGroup1 {
  use type \Foo\Bar\{Baz as Alias};
  use namespace Foo\{Bar\Baz};
}
//##! 1 Trailing comma
namespace Linters\Tests\SingleGroup2 {
  use type Foo\Bar\{Baz};
}
//##! 0 Multiple clauses and direct imports
namespace Linters\Tests\SingleGroup3 {
  use type Foo\Bar\{Baz, Qux};
  use function Foo\Bar\{one, two};
  use namespace Foo\Bar\DirectBaz;
  use type Foo\Bar\DirectQux;
}
//##! 1 Preserve comments
namespace Linters\Tests\SingleGroup5 {
  // Before the import
  use type Foo\Bar\{/* before */Baz/* after *//* comma */}; // After
}
//##! 1 Multiline group
namespace Linters\Tests\SingleGroup6 {
  use type Foo\Bar\{Baz};
}
//##! 1 Namespace blocks
namespace Linters\Tests\SingleGroupBlock {
  use type Foo\Bar\{Baz};
}
