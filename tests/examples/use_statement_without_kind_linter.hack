//##! 3
namespace Linters\Tests\UseStatementWithoutKindLinter;

use One;
use One\Two;
use One\{Three, Four};

//##! 0

use namespace One\Five;
use type One\Six;
use const One\SEVEN;
use function ONE\{eight, nine};
