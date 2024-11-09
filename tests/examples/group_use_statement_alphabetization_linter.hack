//##! 3
namespace Linters\Tests\GroupUseStatementAlphabetizationLinter;

use namespace One\{Two, Three};
use namespace \{Four, Five};
use namespace \{/*1*/One/*a*/\Six/*2*/, /*3*/One/*b*/\Seven/*4*/};

//##! 0
use namespace One\{_Three, _Two};
use namespace \{_Five, _Four};
use namespace \{One\Eight, One\Nine};
