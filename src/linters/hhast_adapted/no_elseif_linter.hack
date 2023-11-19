/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_elseif_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Vec\map(
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_ELSEIF_CLAUSE),
    $f ==> new LintError(
      $script,
      $f,
      $linter,
      'Use else if instead of elseif. '.
      'This syntax will be removed in a future version of hhvm.',
    ),
  );
}
