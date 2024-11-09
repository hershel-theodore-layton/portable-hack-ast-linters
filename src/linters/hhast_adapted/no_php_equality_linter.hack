/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_php_equality_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_eq = Pha\create_token_matcher($script, Pha\KIND_EQUAL_EQUAL);

  return Vec\concat(
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_EQUAL_EQUAL),
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_EXCLAMATION_EQUAL),
  )
    |> Vec\map(
      $$,
      $n ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $n,
        $linter,
        'Do not use `==` or `!=`. '.
        'The behaviors of these operators are difficult to explain.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $n,
            $is_eq($n) ? '===' : '!==',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      ),
    );
}
