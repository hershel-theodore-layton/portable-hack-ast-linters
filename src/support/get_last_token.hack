/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function get_last_token(
  Pha\Script $script,
  Pha\NillableNode $node,
)[]: Pha\NillableToken {
  return Pha\as_token_or_nil(
    !Pha\is_token($node)
      ? Pha\node_get_descendants($script, $node)
        |> Vec\reverse($$)
        |> C\find($$, Pha\is_token<>) ?? Pha\NIL
      : $node,
  );
}
