//##! 4 All explicit import kinds.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use namespace Zed, Alpha, Middle;
use type D, C, B, A;
use function zed, alpha, middle;
use const ZED, ALPHA, MIDDLE;

//##! 0 Already sorted clauses.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use namespace Alpha, Middle, Zed;
use type A, B, C, D;
use function alpha, middle, zed;
use const ALPHA, MIDDLE, ZED;

//##! 1 Sort by the full qualified name.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use type Z\First, A\Last, M\Middle;

//##! 1 Multiple lines retain their layout.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use type
  D,
  C,
  B,
  A;

//##! 1 Comments follow the same retention rules as grouped clauses.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use type /* first */ Z/* inside Z */\Last /* after first */,
  /* second */ A/* inside A */\First /* after second */;

//##! 0 Single clauses do not need sorting.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use namespace Zed;
use type D;
use function zed;
use const ZED;

//##! 0 Grouped clauses have their own linter.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use namespace HH\Lib\{Vec, Str};
use type Foo\{D, C, B, A};

//##! 0 Separate statements have their own linter.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use type Zed;
use type Alpha;

//##! 1 Implicit-kind clauses can also be sorted.
namespace Linters\Tests\UseStatementAlphabetizationLinter;
use Zed, Alpha, Middle;
