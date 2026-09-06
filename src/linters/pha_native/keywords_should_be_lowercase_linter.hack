/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function keywords_should_be_lowercase_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Vec\concat(
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_BOOLEAN_LITERAL),
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_NULL_LITERAL),
  )
    |> Vec\filter($$, $token ==> {
      $text = Pha\token_get_text($script, $token);
      return $text !== Str\lowercase($text);
    })
    |> Vec\map($$, $token ==> {
      $lowercase = Pha\token_get_text($script, $token) |> Str\lowercase($$);
      return LintError::createWithPatches(
        $script,
        $pragma_map,
        $token,
        $linter,
        'Use the canonical lowercase spelling `'.$lowercase.'`.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $token,
            $lowercase,
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      );
    });
}
