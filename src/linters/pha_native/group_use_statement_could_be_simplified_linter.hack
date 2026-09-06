/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function group_use_statement_could_be_simplified_linter(
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
  $get_left_brace = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_GROUP_USE_LEFT_BRACE,
  );
  $get_right_brace = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_GROUP_USE_RIGHT_BRACE,
  );
  $get_separator =
    Pha\create_member_accessor($script, Pha\MEMBER_LIST_SEPARATOR);

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  )
    |> Vec\filter($$, $use ==> {
      $clauses = Pha\list_get_items_of_children($script, $get_clauses($use));
      return C\count($clauses) === 1;
    })
    |> Vec\map($$, $use ==> {
      $clauses = $get_clauses($use);
      $separator = Pha\node_get_children($script, $clauses)
        |> C\onlyx($$)
        |> Pha\as_syntax($$)
        |> $get_separator($$);

      $patches = vec[
        Pha\patch_node(
          $get_left_brace($use),
          '',
          shape('trivia' => Pha\RetainTrivia::BOTH),
        ),
        Pha\patch_node(
          $get_right_brace($use),
          '',
          shape('trivia' => Pha\RetainTrivia::BOTH),
        ),
      ];
      if (!Pha\is_missing($separator)) {
        $patches[] = Pha\patch_node(
          $separator,
          '',
          shape('trivia' => Pha\RetainTrivia::BOTH),
        );
      }

      return LintError::createWithPatches(
        $script,
        $pragma_map,
        $use,
        $linter,
        'This group use statement does not need to be a group use statement.',
        Pha\patches($script, ...$patches),
      );
    });
}
