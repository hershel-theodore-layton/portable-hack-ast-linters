/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_elseif_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Vec\map(
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_ELSEIF),
    $f ==> LintError::createWithPatches(
      $script,
      $pragma_map,
      $f,
      $linter,
      'Use else if instead of elseif. '.
      'This syntax will be removed in a future version of hhvm.',
      Pha\patches($script, Pha\patch_node(
        $f,
        'else if',
        shape('trivia' => Pha\RetainTrivia::BOTH),
      )),
    ),
  );
}
