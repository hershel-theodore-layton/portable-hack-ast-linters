/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function no_final_method_in_final_classes_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_classish_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_CLASSISH_DECLARATION);
  $is_final = Pha\create_token_matcher($script, Pha\KIND_FINAL);

  $get_classish_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_MODIFIERS);
  $get_method_function_decl = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
  )
    |> Pha\returns_syntax($$);
  $get_function_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_MODIFIERS);
  $get_function_name =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_NAME);

  $any_child_is_final = $node ==>
    C\any(Pha\node_get_children($script, $node), $is_final);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_METHODISH_DECLARATION)
    |> Vec\filter(
      $$,
      $method ==> (
        $get_method_function_decl($method)
        |> $get_function_modifiers($$)
        |> $any_child_is_final($$)
      ) &&
        (
          Pha\node_get_syntax_ancestors($script, $method)
          |> C\findx($$, $is_classish_declaration)
          |> $get_classish_modifiers($$)
          |> $any_child_is_final($$)
        ),
    )
    |> Vec\map(
      $$,
      $f ==> LintError::create(
        $script,
        $pragma_map,
        $get_method_function_decl($f) |> $get_function_name($$),
        $linter,
        'Remove the final keyword. The surrounding class is already final.',
      ),
    );
}
