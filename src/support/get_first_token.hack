/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\C;
use namespace HTL\Pha;

function get_first_token(
  Pha\Script $script,
  Pha\NillableNode $node,
)[]: Pha\NillableToken {
  return Pha\node_get_descendants($script, $node)
    |> C\find($$, Pha\is_token<>) ?? Pha\NIL
    |> Pha\as_token_or_nil($$);
}
