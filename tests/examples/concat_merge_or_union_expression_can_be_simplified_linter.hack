//##! 3
namespace Linters\Tests\ConcatMergeOrUnionExpressionCanBeSimplifiedLinter;

use namespace HH\Lib\{Dict, Keyset, Vec};

function func1(): void {
  Dict\merge(dict[]);
  Keyset\union(keyset[]);
  Vec\concat(vec[]);
}

//##! 1 Multi arg calls are okay.
use function HH\Lib\Dict\merge;
use function HH\Lib\Keyset\union;
use function HH\Lib\Vec\concat;

function func2(): void {
  concat(vec[]);

  merge(dict[], dict[]);
  union(keyset[], keyset[]);
  concat(vec[], vec[]);
}

//##! 0 Spreading a tuple is okay, since we can't know the arity of the tuple.

function func3(): void {
  $tuple = tuple(dict[]);

  \HH\Lib\Vec\concat(...$tuple);
}
