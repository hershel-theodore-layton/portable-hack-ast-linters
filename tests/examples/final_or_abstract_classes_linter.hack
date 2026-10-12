//##! 1
namespace Linters\Tests\FinalOrAbstractClassesLinter;

class X1 {}

//##! 0

interface X2 {}

enum X3: int {}

final class X4 {}

abstract class X5 {}

final abstract class X6 {}

//##! 1

<<__ConsistentConstruct>> class Attributed {}

//##! 1

<<__ConsistentConstruct, __DynamicallyConstructible>>
/* Keep the class comment. */
class MultipleAttributes {}

//##! 1

<<__ConsistentConstruct>>
xhp /* Keep the modifier comment. */ class XhpClass {}

//##! 0

<<__ConsistentConstruct>> final class AlreadyFinal {}

<<__ConsistentConstruct>> abstract class AlreadyAbstract {}
