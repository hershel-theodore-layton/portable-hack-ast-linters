//##! 0
namespace Linters\Tests\NamespacePrivateSymbolLinter;

//##! 0 Setting up some private names
namespace A\_Private;
const int PRIV = 0;

//##! 0 Setting up some private names
namespace A\__Private;
const int PRIV = 0;

//##! 0 Setting up some private names
namespace A\Hi\HelloThere\_Private;
const int PRIV = 0;

//##! 2
namespace B;

const int PRIV = \A\_Private\PRIV;
const int PRIV2 = \A\__Private\PRIV;

//##! 0
namespace A\SomeSubNamespace;

use namespace A\Hi\HelloThere;

const int PRIV = \A\Hi\HelloThere\_Private\PRIV;
const int PRIV2 = HelloThere\_Private\PRIV;
