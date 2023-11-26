//##! 3
namespace Linters\Tests\UnneededConcatMergeOrUnionCall;

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
