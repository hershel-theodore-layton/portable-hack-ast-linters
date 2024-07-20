/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_empty_statements_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_always_empty_expression = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_ANONYMOUS_FUNCTION,
    Pha\KIND_CAST_EXPRESSION,
    Pha\KIND_COLLECTION_LITERAL_EXPRESSION,
    Pha\KIND_DARRAY_INTRINSIC_EXPRESSION,
    Pha\KIND_DICTIONARY_INTRINSIC_EXPRESSION,
    Pha\KIND_IS_EXPRESSION,
    Pha\KIND_ISSET_EXPRESSION,
    Pha\KIND_KEYSET_INTRINSIC_EXPRESSION,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_LITERAL,
    Pha\KIND_MISSING,
    Pha\KIND_NAME_EXPRESSION,
    Pha\KIND_SUBSCRIPT_EXPRESSION,
    Pha\KIND_VECTOR_INTRINSIC_EXPRESSION,
    Pha\KIND_VARIABLE_SYNTAX,
    Pha\KIND_VARRAY_INTRINSIC_EXPRESSION,
  );

  $is_binary_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_BINARY_EXPRESSION);

  $is_parenthesized_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_PARENTHESIZED_EXPRESSION);

  $is_side_effecty_operator = Pha\create_token_matcher(
    $script,
    Pha\KIND_AMPERSAND_EQUAL,
    Pha\KIND_BAR_EQUAL,
    Pha\KIND_CARAT_EQUAL,
    Pha\KIND_DOT_EQUAL,
    Pha\KIND_EQUAL,
    Pha\KIND_GREATER_THAN_GREATER_THAN_EQUAL,
    Pha\KIND_LESS_THAN_LESS_THAN_EQUAL,
    Pha\KIND_MINUS_EQUAL,
    Pha\KIND_PERCENT_EQUAL,
    Pha\KIND_PLUS_EQUAL,
    Pha\KIND_QUESTION_QUESTION_EQUAL,
    Pha\KIND_SLASH_EQUAL,
    Pha\KIND_STAR_EQUAL,
    Pha\KIND_STAR_STAR_EQUAL,
    // The `|>` operator has no side-effect, but this common idiom needs to be ok.
    // `some_cumbersome_expr |> side_effecty_function($$);`
    // This is preferred when this results in easier to read code.
    // Is is not always possible to use a discard statement `$_ = ...`,
    // since the type of this expression may be void.
    // Assigned void to `$_` is not allowed.
    Pha\KIND_BAR_GREATER_THAN,
  );

  $get_binop_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);

  $get_expression = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_EXPRESSION_STATEMENT_EXPRESSION,
  );

  $get_parenthesized_expression_expression = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_PARENTHESIZED_EXPRESSION_EXPRESSION,
  );

  $expression_is_empty = $node ==> {
    while ($is_parenthesized_expression($node)) {
      $node = $get_parenthesized_expression_expression(Pha\as_syntax($node));
    }

    return $is_always_empty_expression($node) ||
      (
        $is_binary_expression($node) &&
        (
          $node
          |> Pha\as_syntax($$)
          |> $get_binop_operator($$)
          |> !$is_side_effecty_operator($$)
        )
      );
  };

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_EXPRESSION_STATEMENT)
    |> Vec\map($$, $get_expression)
    |> Vec\filter($$, $expression_is_empty)
    |> Vec\map(
      $$,
      $expr ==> LintError::create(
        $script,
        $pragma_map,
        $expr,
        $linter,
        'You are not using the result of this expression. '.
        'You can silence this warning by assigning it to `$_`.',
      ),
    );
}
