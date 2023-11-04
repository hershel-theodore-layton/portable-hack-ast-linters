/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function no_final_method_in_final_classes_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_classish_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_CLASSISH_DECLARATION);

  $is_final = Pha\create_token_matcher($script, Pha\KIND_FINAL);

  $any_child_is_final = $node ==>
    C\any(Pha\node_get_children($script, $node), $is_final);

  $multi_member = (Pha\Syntax $node, Pha\Member ...$members) ==> {
    foreach ($members as $m) {
      $node = Pha\syntax_member($script, Pha\as_syntax($node), $m);
    }
    return $node;
  };

  return Pha\script_get_nodes_by_kind(
    $script,
    $syntax_index,
    Pha\KIND_METHODISH_DECLARATION,
  )
    |> Vec\filter(
      $$,
      $method ==> (
        $multi_member(
          $method,
          Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
          Pha\MEMBER_FUNCTION_MODIFIERS,
        )
        |> $any_child_is_final($$)
      ) &&
        (
          Pha\node_get_syntax_ancestors($script, $method)
          |> C\findx($$, $is_classish_declaration)
          |> $multi_member($$, Pha\MEMBER_CLASSISH_MODIFIERS)
          |> $any_child_is_final($$)
        ),
    )
    |> Vec\map(
      $$,
      $f ==> new LintError(
        $script,
        $f,
        $linter,
        'Remove the final keyword. The surrounding class is already final.',
      ),
    );
}
