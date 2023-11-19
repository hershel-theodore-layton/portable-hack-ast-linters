/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function dont_await_in_a_loop_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  // Only includes possible direct statement parents of the await expression.
  // Those marked with `// (...)` indicate that the await must be a expression
  // inside of the parens, not the body, since these structures usually have
  // a statement list `{}` as their body. If you do something like:
  // `if (...) await x;` this fails to hold.
  $is_statement = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_DO_STATEMENT, // (...)
    Pha\KIND_ECHO_STATEMENT,
    Pha\KIND_EXPRESSION_STATEMENT,
    Pha\KIND_FOR_STATEMENT, // (...)
    Pha\KIND_FOREACH_STATEMENT, // (...)
    Pha\KIND_IF_STATEMENT, // (...)
    Pha\KIND_RETURN_STATEMENT,
    Pha\KIND_SWITCH_STATEMENT, // (...)
    Pha\KIND_THROW_STATEMENT,
    Pha\KIND_USING_STATEMENT_BLOCK_SCOPED, // (...)
    Pha\KIND_USING_STATEMENT_FUNCTION_SCOPED, // (...)
    Pha\KIND_WHILE_STATEMENT, // (...)
  );
  $is_boundary = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_ANONYMOUS_FUNCTION,
    Pha\KIND_AWAITABLE_CREATION_EXPRESSION,
    Pha\KIND_FUNCTION_DECLARATION,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_METHODISH_DECLARATION,
    Pha\KIND_DO_STATEMENT,
    Pha\KIND_FOR_STATEMENT,
    Pha\KIND_FOREACH_STATEMENT,
    Pha\KIND_WHILE_STATEMENT,
  );
  $is_loop = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_DO_STATEMENT,
    Pha\KIND_FOR_STATEMENT,
    Pha\KIND_FOREACH_STATEMENT,
    Pha\KIND_WHILE_STATEMENT,
  );
  $is_terminal_statement = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_RETURN_STATEMENT,
    Pha\KIND_THROW_STATEMENT,
  );
  $is_prefix_unary_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_PREFIX_UNARY_EXPRESSION);
  $is_for_or_foreach_statement = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_FOR_STATEMENT,
    Pha\KIND_FOREACH_STATEMENT,
  );

  $get_non_looping_part_of_loop = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_FOR_INITIALIZER,
    Pha\MEMBER_FOREACH_COLLECTION,
  );

  return Vec\filter(
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_AWAIT),
    $await ==> {
      if (!$is_prefix_unary_expression(Pha\node_get_parent($script, $await))) {
        return false;
      }

      $boundary = Pha\node_get_syntax_ancestors($script, $await)
        |> C\findx($$, $is_boundary);

      if (
        !$is_loop($boundary) ||
        $is_for_or_foreach_statement($boundary) &&
          C\contains(
            Pha\node_get_ancestors($script, $await),
            $get_non_looping_part_of_loop($boundary),
          )
      ) {
        return false;
      }

      $statement = Pha\node_get_ancestors($script, $await)
        |> C\findx($$, $is_statement);

      // Allow an await in a loop if the this block ends with a
      // return or throw statement, since no effective parrallism is lost.
      return Pha\node_get_parent($script, $statement)
        |> Pha\node_get_children($script, $$)
        |> Vec\slice($$, C\find_key($$, $n ==> $n === $statement) as nonnull)
        |> !C\any($$, $is_terminal_statement);
    },
  )
    |> Vec\map(
      $$,
      $await_token ==> new LintError(
        $script,
        // Blame the whole expression, not just the token.
        Pha\token_get_parent($script, $await_token),
        $linter,
        'Do not await in a loop.',
      ),
    );
}
