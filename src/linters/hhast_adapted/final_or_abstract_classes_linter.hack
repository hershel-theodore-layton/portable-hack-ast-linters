/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function final_or_abstract_classes_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_class = Pha\create_token_matcher($script, Pha\KIND_CLASS);
  $is_abstract_or_final =
    Pha\create_token_matcher($script, Pha\KIND_ABSTRACT, Pha\KIND_FINAL);

  $get_class_name =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_NAME);
  $get_class_keyword =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_KEYWORD);
  $get_classish_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_MODIFIERS);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_CLASSISH_DECLARATION)
    |> Vec\filter(
      $$,
      $c ==> $is_class($get_class_keyword($c)) &&
        (
          $get_classish_modifiers($c)
          |> Pha\node_get_children($script, $$)
          |> !C\any($$, $is_abstract_or_final)
        ),
    )
    |> Vec\map(
      $$,
      $c ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $get_class_name($c),
        $linter,
        'Classes should be abstract or final.',
        Pha\patches($script, Pha\patch_node(
          $c,
          'final '.
          Pha\node_get_code_without_leading_or_trailing_trivia($script, $c),
          shape('trivia' => Pha\RetainTrivia::BOTH),
        )),
      ),
    );
}
