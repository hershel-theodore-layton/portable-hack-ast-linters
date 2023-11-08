/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function qualified_name_to_string(
  Pha\Script $script,
  Pha\Syntax $qualified_name,
  (function(Pha\Syntax)[]: Pha\Node) $qualified_name_get_parts,
)[]: string {
  return $qualified_name_get_parts($qualified_name)
    |> Pha\as_syntax($$)
    |> Pha\list_get_items_of_children($script, $$)
    |> Vec\map($$, $p ==> Pha\token_get_text($script, Pha\as_token($p)))
    |> Str\join($$, '\\');
}
