/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{Str};
use namespace HTL\Pha;

function insert_digest(
  Pha\Script $script,
  Pha\PragmaMap $pragma_map,
)[]: string {
  $example = "<<file: Pragmas(vec['PhaLinters', 'digest:'])>>";
  $digest = extract_digest($script, $pragma_map);

  invariant(
    $digest is nonnull,
    'The source should contain a pragma attribute with an empty digest, got none. Example: %s',
    $example,
  );
  invariant(
    $digest['embedded'] === '',
    'The embedded pragma directive should not specify a digest, got %s. Example: %s',
    $digest['embedded'],
    $example,
  );

  return Pha\node_get_code($script, $digest['pragma'])
    |> Str\replace($$, 'digest:', 'digest:'.$digest['hashed'])
    |> Pha\patches($script, Pha\patch_node($digest['pragma'], $$))
    |> Pha\patches_apply($$);
}
