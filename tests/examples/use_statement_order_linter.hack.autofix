//##! 1 Separate imports are ordered by their full names.
namespace Linters\Tests\UseStatementOrder;
use namespace HTL\Pragmas;
use namespace HH\Lib\Vec;

//##! 0 Sorted imports.
namespace Linters\Tests\UseStatementOrder;
use namespace HH\Lib\Vec;
use namespace HTL\Pragmas;

//##! 0 Kind takes precedence over prefix.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
use type Y\Thing;
use function X\call;
use const W\VALUE;

//##! 1 A reversed run produces one diagnostic.
namespace Linters\Tests\UseStatementOrder;
use const A\VALUE;
use function B\call;
use type C\Thing;
use namespace D\Ns;

//##! 0 All kinds sort by prefix, including grouped declarations.
namespace Linters\Tests\UseStatementOrder;
use namespace A\{Z, Y};
use namespace A\B;
use type B\{Z, Y};
use type B\C;
use function C\{z, y};
use function C\d;
use const D\{Z, Y};
use const D\E;

//##! 1 A group uses the prefix before the brace, including its backslash.
namespace Linters\Tests\UseStatementOrder;
use namespace HH\Lib\Dict;
use namespace HH\Lib\{Str, Vec};

//##! 0 Equal group prefixes do not depend on their members.
namespace Linters\Tests\UseStatementOrder;
use namespace HH\Lib\{Vec};
use namespace HH\Lib\{Str};

//##! 0 A bare namespace sorts before its subnamespace group.
namespace Linters\Tests\UseStatementOrder;
use namespace HH\Lib;
use namespace HH\Lib\{Str, Vec};

//##! 0 File attributes split runs, even without a semicolon.
namespace Linters\Tests\UseStatementOrder;
use type HTL\Pragma\Pragmas;
<<file: Pragmas()>>
use namespace HH\Lib\Vec;

//##! 0 A file attribute followed by a semicolon also splits runs.
namespace Linters\Tests\UseStatementOrder;
use type HTL\Pragma\Pragmas;
<<file: Pragmas(vec['PhaLinters'])>>
;
use namespace HH\Lib\Vec;

//##! 2 Both sides of a file attribute are checked independently.
namespace Linters\Tests\UseStatementOrder;
use type Z\Thing;
use type HTL\Pragma\Pragmas;
<<file: Pragmas(vec['PhaLinters'])>>
use namespace HTL\Pragmas;
use namespace HH\Lib\Vec;

//##! 0 Other declarations split runs.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
function separator(): void {}
use namespace A\ANs;

//##! 1 Comments and blank lines do not split a run.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs; // Attached comment.

/* Another comment. */
use namespace A\ANs;

//##! 0 Namespace boundaries split runs.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
namespace Linters\Tests\UseStatementOrder;
use namespace A\ANs;

//##! 2 Namespace runs are checked independently.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
use namespace Y\YNs;
namespace Linters\Tests\UseStatementOrder;
use namespace B\BNs;
use namespace A\ANs;

//##! 0 Already ordered namespaces do not share a run.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
namespace Linters\Tests\UseStatementOrder;
use namespace A\ANs;

//##! 0 Leading backslashes do not affect ordering.
namespace Linters\Tests\UseStatementOrder;
use namespace \A\First;
use namespace B\Second;

//##! 1 A comma-separated declaration uses its first full name.
namespace Linters\Tests\UseStatementOrder;
use type Z\ZThing, A\AThing;
use type B\Thing;

//##! 0 Imports without a kind are left to use_statement_without_kind_linter.
namespace Linters\Tests\UseStatementOrder;
use namespace Z\ZNs;
use Some\Thing;
use namespace A\ANs;

//##! 1 An unknown kind does not disable later runs.
namespace Linters\Tests\UseStatementOrder;
use Some\Thing;
use namespace Z\ZNs;
use namespace A\ANs;

//##! 0 Empty input and non-import uses do not form runs.
namespace Linters\Tests\UseStatementOrder;
use type Linters\Tests\UseStatementOrder\SomeTrait;

class Example {
  use SomeTrait;
}
function capture(): void {
  $value = 1;
  $closure = function(): int use ($value) {
    return $value;
  };
}

//##! 3 Each remaining kind is checked for prefix order.
namespace Linters\Tests\UseStatementOrder;
use type Z\Thing;
use type A\OtherThing;
function first_separator(): void {}
use function Z\call;
use function A\other_call;
function second_separator(): void {}
use const Z\VALUE;
use const A\OTHER_VALUE;

//##! 1 A group prefix keeps its trailing backslash for comparison.
namespace Linters\Tests\UseStatementOrder;
use namespace A\{B};
use namespace A;

//##! 0 No declarations.
namespace Linters\Tests\UseStatementOrder;

//##! 0 Supporting declarations.
namespace Linters\Tests\UseStatementOrder;
trait SomeTrait {}
