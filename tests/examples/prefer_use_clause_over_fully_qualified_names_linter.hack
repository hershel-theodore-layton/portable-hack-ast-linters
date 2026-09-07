//##! 0
namespace Linters\Tests\PreferUseClause;

use namespace \HH\Lib\Str;
use namespace \HH\Lib\{C, Vec};
use function \strlen;
use const \PHP_INT_MAX;
use type \Exception;

function example(Exception $e): int {
  Str\length('example');
  Vec\map(vec[], $x ==> $x);
  C\is_empty(vec[]);
  strlen('example');
  return PHP_INT_MAX;
}

//##! 4
namespace Linters\Tests\PreferUseClauseQualified;

function example(\Exception $e): int {
  \HH\Lib\Str\length('example');
  \strlen('example');
  return \PHP_INT_MAX;
}
