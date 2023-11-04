/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function prefer_lambdas_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Pha\script_get_nodes_by_kind(
    $script,
    $syntax_index,
    Pha\KIND_ANONYMOUS_FUNCTION,
  )
    |> Vec\map(
      $$,
      $f ==> new LintError(
        $script,
        $f,
        $linter,
        'Prefer `() ==> {}` lambdas over `function () {}`.',
      ),
    );
}
