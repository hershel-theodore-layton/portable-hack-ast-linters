/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_newline_at_start_of_control_flow_block_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_eol = Pha\create_trivium_matcher($script, Pha\KIND_END_OF_LINE);
  $is_function_body = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_FUNCTION_DECLARATION,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_METHODISH_DECLARATION,
  );

  $get_closing_curly =
    Pha\create_member_accessor($script, Pha\MEMBER_COMPOUND_RIGHT_BRACE);
  $get_statements =
    Pha\create_member_accessor($script, Pha\MEMBER_COMPOUND_STATEMENTS);

  $get_first_statement_or_closing_curly = $compound ==>
    $get_statements($compound)
    |> Pha\node_get_first_child($script, $$)
    |> $$ === Pha\NIL ? $get_closing_curly($compound) : Pha\as_nonnil($$);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_COMPOUND_STATEMENT)
    |> Vec\filter(
      $$,
      $stmt ==> Pha\node_get_parent($script, $stmt) |> !$is_function_body($$),
    )
    |> Vec\map(
      $$,
      $stmt ==> $get_first_statement_or_closing_curly($stmt)
        |> Support\get_first_token($script, $$)
        |> Pha\node_get_first_child($script, $$),
    )
    |> Vec\filter($$, $is_eol)
    |> Vec\map($$, Pha\as_nonnil<>)
    |> Vec\map(
      $$,
      $eol ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        Pha\as_nonnil($eol),
        $linter,
        'Control flow blocks may not start with an empty line.',
        Pha\patches($script, Pha\patch_node($eol, '')),
      ),
    );
}
