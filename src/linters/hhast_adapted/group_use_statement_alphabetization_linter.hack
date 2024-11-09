/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function group_use_statement_alphabetization_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_clauses =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_CLAUSES)
    |> Pha\returns_syntax($$);

  $get_use_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);

  $get_uses_to_be_sorted = $group_use ==> $get_clauses($group_use)
    |> Pha\list_get_items_of_children($script, $$);

  $autofix = $group_use ==> {
    $old_order = $get_uses_to_be_sorted($group_use);
    $new_order = Vec\sort_by(
      $old_order,
      $c ==> Pha\as_syntax($c)
        |> $get_use_name($$)
        |> Pha\node_get_code_compressed($script, $$),
    );
    return Vec\zip($old_order, $new_order)
      |> Vec\map(
        $$,
        $tuple ==> vec[
          Pha\patch_node(
            $tuple[0],
            Pha\node_get_code_without_leading_or_trailing_trivia(
              $script,
              $tuple[1],
            ),
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ],
      )
      |> Vec\flatten($$)
      |> Pha\patches($script, ...$$);
  };

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  )
    |> Vec\filter(
      $$,
      $group_use ==> $get_uses_to_be_sorted($group_use)
        |> Vec\map(
          $$,
          $clause ==> Pha\as_syntax($clause)
            |> $get_use_name($$)
            |> Pha\node_get_code_compressed($script, $$),
        )
        |> !C\is_sorted($$),
    )
    |> Vec\map(
      $$,
      $group_use ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $group_use,
        $linter,
        'Group use clauses should be sorted alphabetically.',
        $autofix($group_use),
      ),
    );
}
