/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;
use function sha1;

function extract_digest(
  Pha\Script $script,
  Pha\PragmaMap $pragma_map,
)[]: ?shape(
  'pragma' => Pha\Syntax,
  'embedded' => string,
  'hashed' => string,
  // @closed-shape
) {
  list($pragma, $digest) = $pragma_map->getAllPragmas()
    |> C\find(
      $$,
      $p ==> C\count($p[2]) === 2 &&
        (
          Str\trim($p[2][0], '"\'')
          |> $$ === 'PhaLinters' || $$ === 'HTL\\PhaLinters'
        ) &&
        (Str\trim($p[2][1], '"\'') |> Str\starts_with($$, 'digest:')),
    )
    |> $$ is nonnull
      ? tuple(
          $$[0],
          Str\trim($$[2][1], '"\'') |> Str\strip_prefix($$, 'digest:'),
        )
      : tuple(null, '');

  if ($pragma is null) {
    return null;
  }

  return Pha\node_get_code($script, Pha\SCRIPT_NODE)
    |> Str\replace($$, $digest, '')
    |> sha1($$)
    |> Str\slice($$, 0, 20)
    |> shape('pragma' => $pragma, 'embedded' => $digest, 'hashed' => $$);
}
