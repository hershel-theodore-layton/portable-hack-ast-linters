/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function negated_is_expression_does_not_need_parens_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_not = Pha\create_token_matcher($script, Pha\KIND_EXCLAMATION);
  $is_logical = Pha\create_token_matcher(
    $script,
    Pha\KIND_AMPERSAND_AMPERSAND,
    Pha\KIND_BAR_BAR,
  );
  $is_equal = Pha\create_token_matcher($script, Pha\KIND_EQUAL);
  $is_parenthesized =
    Pha\create_syntax_matcher($script, Pha\KIND_PARENTHESIZED_EXPRESSION);
  $is_is = Pha\create_syntax_matcher($script, Pha\KIND_IS_EXPRESSION);
  $is_binary = Pha\create_syntax_matcher($script, Pha\KIND_BINARY_EXPRESSION);
  $is_list = Pha\create_syntax_matcher($script, Pha\KIND_NODE_LIST);
  $is_list_item = Pha\create_syntax_matcher($script, Pha\KIND_LIST_ITEM);
  $get_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_PREFIX_UNARY_OPERATOR);
  $get_operand =
    Pha\create_member_accessor($script, Pha\MEMBER_PREFIX_UNARY_OPERAND);
  $get_inner = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_PARENTHESIZED_EXPRESSION_EXPRESSION,
  );
  $get_binary_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);
  $get_left_paren = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_PARENTHESIZED_EXPRESSION_LEFT_PAREN,
  );
  $get_right_paren = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_PARENTHESIZED_EXPRESSION_RIGHT_PAREN,
  );

  $is_standalone_parent = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_EXPRESSION_STATEMENT,
    Pha\KIND_RETURN_STATEMENT,
    Pha\KIND_IF_STATEMENT,
    Pha\KIND_ELSEIF_CLAUSE,
    Pha\KIND_WHILE_STATEMENT,
    Pha\KIND_DO_STATEMENT,
    Pha\KIND_FOR_STATEMENT,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_SIMPLE_INITIALIZER,
  );
  $get_standalone_expression = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_EXPRESSION_STATEMENT_EXPRESSION,
    Pha\MEMBER_RETURN_EXPRESSION,
    Pha\MEMBER_IF_CONDITION,
    Pha\MEMBER_ELSEIF_CONDITION,
    Pha\MEMBER_WHILE_CONDITION,
    Pha\MEMBER_DO_CONDITION,
    Pha\MEMBER_FOR_CONTROL,
    Pha\MEMBER_LAMBDA_BODY,
    Pha\MEMBER_SIMPLE_INITIALIZER_VALUE,
  );

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_PREFIX_UNARY_EXPRESSION)
    |> Vec\filter(
      $$,
      $expr ==> $get_operand($expr)
        |> $is_not($get_operator($expr)) &&
          $is_parenthesized($$) &&
          $is_is($get_inner(Pha\as_syntax($$))),
    )
    |> Vec\filter($$, $expr ==> {
      $parent = Pha\syntax_get_parent($script, $expr);
      if ($is_binary($parent)) {
        $operator = $get_binary_operator($parent);
        return $is_logical($operator) || $is_equal($operator);
      }

      if ($is_list_item($parent)) {
        $parent = Pha\syntax_get_parent($script, $parent);
      }
      if ($is_list($parent)) {
        return true;
      }
      return $is_standalone_parent($parent) &&
        $get_standalone_expression($parent) === $expr;
    })
    |> Vec\map($$, $expr ==> {
      $operand = Pha\as_syntax($get_operand($expr));
      return LintError::createWithPatches(
        $script,
        $pragma_map,
        $operand,
        $linter,
        'The parentheses around this negated `is` expression are unnecessary.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $get_left_paren($operand),
            '',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
          Pha\patch_node(
            $get_right_paren($operand),
            '',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      );
    });
}
