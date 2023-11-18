//##! 0
namespace Linters\Tests\UnusedUseClauseLinter;

use namespace HTL\Pha;

const Pha\Syntax NIL = Pha\SCRIPT_NODE;

//##! 1 Unused namespace
use namespace HH\Lib\NotVec;
use namespace HH\Lib\Vec;

function func1(): void {
  Vec\map<>;
}

//##! 1 Unused function
use function HH\Lib\Vec\not_map;
use function HH\Lib\Vec\map;

function func2(): void {
  map(vec[], $x ==> $x);
}

//##! 1 Unused type
use type HH\Lib\NotRef;
use type HH\Lib\Ref;

function func3(): Ref<int> {
  throw new \Exception('Only used in a type position.');
}

//##! 1 Unused const
use const HTL\Pha\SCRIPT_NODE;
use const HTL\Pha\NIL;

const Pha\NillableNode NIL2 = NIL;

//##! 0 Alias
use type HH\Lib\Ref as AliasRef;
use function HH\Lib\Vec\map as alias_map;
use const HTL\Pha\NIL as ALIAS_NIL;
use namespace HH\Lib\Vec as AliasVec;

function func4(): AliasRef<int> {
  alias_map<>;
  ALIAS_NIL;
  AliasVec\map<>;
  return new Ref(1);
}

//##! 2 Group use declaration
use namespace HH\Lib\{C, Dict, Str};

function func5(): void {
  Dict\map<>;
}

//##! 2 Combined use clause
use function not_used, time, also_not_used;

function func6(): void {
  time<>;
}

//##! 1 Used via qualified name
use namespace HH\Lib\Keyset;

function func7(): void {
  \HH\Lib\Keyset\map<>;
}
