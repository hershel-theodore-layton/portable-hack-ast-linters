/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function group_use_statement_alphabetization_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_clauses =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_CLAUSES);

  $get_use_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);

  $get_uses_to_be_sorted = $group_use ==> $get_clauses($group_use)
    |> Pha\as_syntax($$)
    |> Pha\list_get_items_of_children($script, $$);

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
            |> Pha\node_get_code($script, $$),
        )
        |> !C\is_sorted($$),
    )
    |> Vec\map(
      $$,
      $group_use ==> new LintError(
        $script,
        $group_use,
        $linter,
        'Group use clauses should be sorted alphabetically.',
      ),
    );
}
