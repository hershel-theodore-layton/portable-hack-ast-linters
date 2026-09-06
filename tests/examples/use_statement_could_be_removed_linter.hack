//##! 0 No named namespace and imports without a kind
use type Foo\Bar\Thing;

//##! 4 Direct members of the current namespace
namespace Foo\Bar;
use type Foo\Bar\Thing;
use function Foo\Bar\func;
use const Foo\Bar\VALUE;
use namespace Foo\Bar\Sub;

//##! 1 Current namespace prefixes can be replaced with namespace
namespace Foo\Bar;
use namespace Foo\Bar;

//##! 0 Other namespaces and deeper descendants are not direct members
namespace Foo\Bar;
use type Other\Thing;
use function Foo\Barista\func;
use const Foo\Bar\Sub\VALUE;
use namespace Foo;
use type Foo\Bar;
use function Foo\Bar;
use const Foo\Bar;

//##! 3 Leading backslashes, comments, and multiple clauses
namespace Foo\Bar;
use type \Foo\Bar\Thing, Other\OtherThing;
use function Foo\Bar\/* comment */func;
use namespace \Foo\Bar;

//##! 4 Grouped imports use the full name and effective kind
namespace Foo\Bar;
use type Foo\Bar\{Thing, Sub\Other};
use function Foo\Bar\{func};
use const Foo\Bar\{VALUE};
use namespace Foo\{Bar};

//##! 2 Each namespace declaration has its own scope
namespace Foo\Bar;
use type Foo\Bar\Thing;
use type Other\OtherThing;
namespace Other;
use type Foo\Bar\Thing;
use function Other\func;

//##! 0 Direct imports override auto-imported functions and types
namespace Linters\Tests\AutoImportOverrides;
use function Linters\Tests\AutoImportOverrides\idx;
use function Linters\Tests\AutoImportOverrides\invariant;
use type Linters\Tests\AutoImportOverrides\Vector;
use type Linters\Tests\AutoImportOverrides\Awaitable;

//##! 0 Leading backslashes still override auto-imports
namespace Linters\Tests\AutoImportOverrides;
use function \Linters\Tests\AutoImportOverrides\idx;
use type \Linters\Tests\AutoImportOverrides\Vector;

//##! 2 Grouped imports only report the non-auto-imported names
namespace Linters\Tests\AutoImportOverrides;
use function Linters\Tests\AutoImportOverrides\{idx, ordinary_function};
use type Linters\Tests\AutoImportOverrides\{Vector, OrdinaryType};

//##! 4 Auto-import exemptions depend on the import kind
namespace Linters\Tests\AutoImportOverrides;
use type Linters\Tests\AutoImportOverrides\idx;
use function Linters\Tests\AutoImportOverrides\Vector;
use const Linters\Tests\AutoImportOverrides\Vector;
use namespace Linters\Tests\AutoImportOverrides\Awaitable;

//##! 0 Implicit import kinds are outside this linter
namespace Foo\Bar;
use Foo\Bar\Thing;

//##! 0 Empty groups import no members
namespace Foo\Bar;
use type Foo\Bar\{};

//##! 2 Semicolon namespace declarations have separate scopes
namespace Foo\Bar;
use type Foo\Bar\Thing;
namespace Other;
use type Foo\Bar\Thing;
use function Other\func;
