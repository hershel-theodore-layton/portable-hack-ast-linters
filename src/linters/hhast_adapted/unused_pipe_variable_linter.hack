/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function unused_pipe_variable_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_dollar_dollar = Pha\create_token_matcher($script, Pha\KIND_DOLLAR_DOLLAR);
  $is_pipe_arrow = Pha\create_token_matcher($script, Pha\KIND_BAR_GREATER_THAN);

  $get_binop_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);
  $get_binop_rhs =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_RIGHT_OPERAND);

  $is_pipe_expression = $binop ==>
    $get_binop_operator($binop) |> $is_pipe_arrow($$);

  $rhs_uses_dollar_dollar = $binop ==> $get_binop_rhs($binop)
    |> Pha\node_get_descendants($script, $$)
    |> C\any($$, $is_dollar_dollar);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_BINARY_EXPRESSION)
    |> Vec\filter(
      $$,
      $expr ==> $is_pipe_expression($expr) && !$rhs_uses_dollar_dollar($expr),
    )
    |> Vec\map(
      $$,
      $n ==> LintError::createWithoutPatches(
        $script,
        $pragma_map,
        $n,
        $linter,
        'You did not use the $$ variable on the right hand side of the `|>`.',
      ),
    );
}
