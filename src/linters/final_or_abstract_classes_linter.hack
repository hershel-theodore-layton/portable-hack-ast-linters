/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function final_or_abstract_classes_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_class = Pha\create_token_matcher($script, Pha\KIND_CLASS);

  $is_abstract_or_final =
    Pha\create_token_matcher($script, Pha\KIND_ABSTRACT, Pha\KIND_FINAL);

  $get_class_keyword =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_KEYWORD);

  $get_method_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_MODIFIERS);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_CLASSISH_DECLARATION)
    |> Vec\filter(
      $$,
      $c ==> $is_class($get_class_keyword($c)) &&
        (
          $get_method_modifiers($c)
          |> Pha\node_get_children($script, $$)
          |> !C\any($$, $is_abstract_or_final)
        ),
    )
    |> Vec\map(
      $$,
      $c ==> new LintError(
        $script,
        $c,
        $linter,
        'Classes should be abstract or final.',
      ),
    );
}
