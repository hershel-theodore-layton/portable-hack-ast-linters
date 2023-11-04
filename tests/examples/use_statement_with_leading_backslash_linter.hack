//##! 3
namespace Linters\Tests\UseStatementWithLeadingBackslashLinter;

use type \One;
use type \One\Two;
use type \One\{Three, Four};

//##! 0

use type One\Five;
