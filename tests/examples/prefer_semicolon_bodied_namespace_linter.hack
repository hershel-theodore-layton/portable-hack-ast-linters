//##! 1 Empty named namespace
namespace Linters\Tests\SemicolonNamespaceEmpty {}

//##! 1 Nonempty namespace, with unrelated braces inside
namespace Linters\Tests\SemicolonNamespaceNonempty {
  function example(bool $condition): void {
    if ($condition) {
    }
  }

  final class Example {}
}

//##! 2 Multiple namespaces
namespace Linters\Tests\SemicolonNamespaceFirst {}
namespace Linters\Tests\SemicolonNamespaceSecond {}

//##! 1 Comments do not hide the namespace body
// Before the namespace.
namespace Linters\Tests\SemicolonNamespaceComments /* before */ {
  /* inside */
} // After the namespace.

//##! 1 Global namespace
namespace {}

//##! 1 Nonempty global namespace
namespace /* global */ {
  function semicolon_namespace_global_example(): void {}
}

//##! 0 No namespace declaration
