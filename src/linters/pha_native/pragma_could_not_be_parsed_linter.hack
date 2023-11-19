/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function pragma_could_not_be_parsed_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return $pragma_map->getAllPragmas()
    |> Vec\filter(
      $$,
      $p ==> $p[2][0]
        |> Str\trim($$, '"\'')
        |> $$ === 'PhaLinters' || $$ === 'HTL\PhaLinters',
    )
    |> Vec\filter(
      $$,
      $t ==> Vec\drop($t[2], 1)
        |> Vec\map($$, $str ==> Str\trim($str, '"\''))
        |> C\find($$, $str ==> !Str\starts_with($str, 'ignore:')) is nonnull,
    )
    |> Vec\map(
      $$,
      $p ==> new LintError(
        $script,
        $p[0],
        $linter,
        'Your version of PhaLinters only supports ignore:linter_name',
      ),
    );

}
