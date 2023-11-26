//##! 16 All errors
namespace Linters\Tests\CountExpressionCanBeSimplified;

use namespace HH\Lib\C;

function func1(): void {
  $_ = C\count(vec[]) === 0;
  $_ = C\count(vec[]) !== 0;
  $_ = C\count(vec[]) < 0;
  $_ = C\count(vec[]) <= 0;
  $_ = C\count(vec[]) > 0;
  $_ = C\count(vec[]) >= 0;
  $_ = C\count(vec[]) < 1;
  $_ = C\count(vec[]) >= 1;

  $_ = 0 === C\count(vec[]);
  $_ = 0 !== C\count(vec[]);
  $_ = 0 < C\count(vec[]);
  $_ = 0 <= C\count(vec[]);
  $_ = 0 > C\count(vec[]);
  $_ = 0 >= C\count(vec[]);
  $_ = 1 > C\count(vec[]);
  $_ = 1 <= C\count(vec[]);
}

//##! 1 All OK cases, plus one error, just to show that
//      the different use clause didn't change the outcome.
use function HH\Lib\C\count;

function func2(): void {
  $_ = count(vec[]) === 0;

  $_ = count(vec[]) === 1;
  $_ = count(vec[]) !== 1;
  $_ = count(vec[]) <= 1;
  $_ = count(vec[]) > 1;

  $_ = 1 === count(vec[]);
  $_ = 1 !== count(vec[]);
  $_ = 1 < count(vec[]);
  $_ = 1 >= count(vec[]);
}

//##! 0 This also does not trigger for \count(),
//      because of the \Countable interface,
//      which can not be passed to C\is_empty().
function func3(): void {
  $_ = count(vec[]) === 0;
}
