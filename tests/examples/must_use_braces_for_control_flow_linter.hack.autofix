//##! 6
namespace Linters\Tests\MustUseBracesForControlFlowLinter;

function func1(): void {
  if (true)
    echo 4;
  else
    while (true)
      foreach ($a as $b)
        for (; ; )
          do
            echo 5;
          while (true);
}

//##! 0
function func2(): void {
  if (true) {
    echo 4;
  } else {
    while (true) {
      foreach ($a as $b) {
        for (; ; ) {
          do {
            echo 5;
          } while (true);
        }
      }
    }
  }
}
