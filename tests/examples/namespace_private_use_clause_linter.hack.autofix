//##! 0
namespace Linters\Tests\NamespacePrivateUseClauseLinter;
// Empty

//##! 0
namespace A;
use namespace A\_Private as _A;

//##! 3
namespace A;
use namespace B\{_Private, __Private};
use namespace C\_Private as _C;

//##! 0 A is the common prefix.
namespace A\NamespaceOne;
use namespace A\NamespaceTwo\_Private;
