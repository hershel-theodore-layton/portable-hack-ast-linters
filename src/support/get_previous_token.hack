/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HTL\Pha;

function get_previous_token(
  Pha\Script $script,
  Pha\NillableNode $node,
)[]: Pha\NillableToken {
  if ($node === Pha\NIL) {
    return Pha\NIL_TOKEN;
  }

  $family = Pha\as_nonnil($node)
    |> Pha\node_get_parent($script, $$)
    |> Pha\node_get_descendants($script, $$);
  
  $previous_token = Pha\NIL_TOKEN;
  foreach ($family as $f) {
    if ($f === $node) {
      break;
    }

    if (Pha\is_token($f)) {
      $previous_token = Pha\as_token($f);
    }
  }

  return $previous_token;
}
