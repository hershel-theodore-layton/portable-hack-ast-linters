/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function must_use_braces_for_control_flow_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_compound_statement_or_if_statement = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_COMPOUND_STATEMENT,
    Pha\KIND_IF_STATEMENT,
  );

  $get_body = Pha\create_member_accessor($script, dict[
    Pha\KIND_DO_STATEMENT => Pha\MEMBER_DO_BODY,
    Pha\KIND_ELSE_CLAUSE => Pha\MEMBER_ELSE_STATEMENT,
    Pha\KIND_IF_STATEMENT => Pha\MEMBER_IF_STATEMENT,
    Pha\KIND_FOR_STATEMENT => Pha\MEMBER_FOR_BODY,
    Pha\KIND_FOREACH_STATEMENT => Pha\MEMBER_FOREACH_BODY,
    Pha\KIND_WHILE_STATEMENT => Pha\MEMBER_WHILE_BODY,
  ]);

  $is_braceless = ($node) ==>
    $get_body($node) |> !$is_compound_statement_or_if_statement($$);

  return Vec\concat(
    Pha\script_get_nodes_by_kind($script, $syntax_index, Pha\KIND_DO_STATEMENT),
    Pha\script_get_nodes_by_kind($script, $syntax_index, Pha\KIND_ELSE_CLAUSE),
    Pha\script_get_nodes_by_kind($script, $syntax_index, Pha\KIND_IF_STATEMENT),
    Pha\script_get_nodes_by_kind(
      $script,
      $syntax_index,
      Pha\KIND_FOR_STATEMENT,
    ),
    Pha\script_get_nodes_by_kind(
      $script,
      $syntax_index,
      Pha\KIND_FOREACH_STATEMENT,
    ),
    Pha\script_get_nodes_by_kind(
      $script,
      $syntax_index,
      Pha\KIND_WHILE_STATEMENT,
    ),
  )
    |> Vec\filter($$, $is_braceless)
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'Use curly braces {} for control flow.',
      ),
    );
}
