/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

/**
 * Manual inclusion directives are going to be removed from hhvm.
 * This linter allows preadoption of the no-inclusion-directives language change.
 */
function autoload_your_code_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_INCLUSION_EXPRESSION)
    |> Vec\map(
      $$,
      $n ==> LintError::create(
        $script,
        $pragma_map,
        $n,
        $linter,
        'Autoload your code instead of using inclusion directives.',
      ),
    );
}
