//##! 3
namespace Linters\Tests\GroupUseStatementAlphabetizationLinter;

use namespace One\{Two, Three};
use namespace \{Four, Five};
use namespace \{One\Six, One\Seven};

//##! 0
use namespace One\{_Three, _Two};
use namespace \{_Five, _Four};
use namespace \{One\Eight, One\Nine};
