/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function prefer_lambdas_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_ANONYMOUS_FUNCTION)
    |> Vec\map(
      $$,
      $f ==> LintError::create(
        $script,
        $pragma_map,
        $f,
        $linter,
        'Prefer `() ==> {}` lambdas over `function () {}`.',
      ),
    );
}
