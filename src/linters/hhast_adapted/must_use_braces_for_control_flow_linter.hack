/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function must_use_braces_for_control_flow_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_compound_statement =
    Pha\create_syntax_matcher($script, Pha\KIND_COMPOUND_STATEMENT);
  $is_else_clause = Pha\create_syntax_matcher($script, Pha\KIND_ELSE_CLAUSE);
  $is_compound_statement_or_if_statement = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_COMPOUND_STATEMENT,
    Pha\KIND_IF_STATEMENT,
  );

  $get_body = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_DO_BODY,
    Pha\MEMBER_ELSE_STATEMENT,
    Pha\MEMBER_IF_STATEMENT,
    Pha\MEMBER_FOR_BODY,
    Pha\MEMBER_FOREACH_BODY,
    Pha\MEMBER_WHILE_BODY,
  );

  $is_braceless = $node ==> $get_body($node)
    |> !(
      $is_else_clause($node)
        ? $is_compound_statement_or_if_statement($$)
        : $is_compound_statement($$)
    );

  $braceless = Vec\concat(
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_DO_STATEMENT),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_ELSE_CLAUSE),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_IF_STATEMENT),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_FOR_STATEMENT),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_FOREACH_STATEMENT),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_WHILE_STATEMENT),
  )
    |> Vec\filter($$, $is_braceless);

  return Vec\map(
    $braceless,
    $n ==> LintError::createWithPatches(
      $script,
      $pragma_map,
      $n,
      $linter,
      'Use curly braces {} for control flow.',
      // Fix inner bodies first, so nested diagnostics never overlap patches.
      C\any(
        $braceless,
        $other ==> $n !== $other &&
          (
            $other === $get_body($n) ||
            C\contains(
              Pha\node_get_syntax_ancestors($script, $other),
              $get_body($n),
            )
          ),
      )
        ? null
        : Pha\patches($script, Pha\patch_node(
          $get_body($n),
          $get_body($n)
            |> Pha\node_get_code($script, $$)
            |> "{\n ".$$.'}',
        )),
    ),
  );
}
