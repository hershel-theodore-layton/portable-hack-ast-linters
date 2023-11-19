/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function pragma_prefix_unknown_linter(
  Pha\Script $script,
  Pha\PragmaMap $pragma_map,
  keyset<string> $known_pragma_prefixes,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return $pragma_map->getAllPragmas()
    |> Vec\filter(
      $$,
      $p ==> $p[2][0]
        |> Str\trim($$, '"\'')
        |> C\contains_key($known_pragma_prefixes, $$),
    )
    |> Vec\map(
      $$,
      $p ==> new LintError(
        $script,
        $p[0],
        $linter,
        'This pragma prefix is not known. '.
        'Known prefixes: '.
        Str\join($known_pragma_prefixes, ', '),
      ),
    );
}
