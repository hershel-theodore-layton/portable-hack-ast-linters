//##! 1
namespace Linters\Tests\PreferLambdasLinter;

function func1(): void {
  function() use () {};
}

//##! 0

function func2(): void {
  () ==> {};
}
