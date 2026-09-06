/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function assignment_to_empty_list_tuple_or_shape_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_assignment_operator = Pha\create_token_matcher($script, Pha\KIND_EQUAL);
  $get_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);
  $get_lhs =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_LEFT_OPERAND);
  $is_parenthesized =
    Pha\create_syntax_matcher($script, Pha\KIND_PARENTHESIZED_EXPRESSION);
  $get_inner = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_PARENTHESIZED_EXPRESSION_EXPRESSION,
  );

  $is_destructuring = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_LIST_EXPRESSION,
    Pha\KIND_TUPLE_EXPRESSION,
    Pha\KIND_SHAPE_EXPRESSION,
  );
  $get_members = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_LIST_MEMBERS,
    Pha\MEMBER_TUPLE_EXPRESSION_ITEMS,
    Pha\MEMBER_SHAPE_EXPRESSION_FIELDS,
  );

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_BINARY_EXPRESSION)
    |> Vec\filter($$, $expr ==> $is_assignment_operator($get_operator($expr)))
    |> Vec\filter($$, $expr ==> {
      $lhs = $get_lhs($expr);
      while ($is_parenthesized($lhs)) {
        $lhs = $get_inner(Pha\as_syntax($lhs));
      }
      return $is_destructuring($lhs) &&
        Pha\is_missing($get_members(Pha\as_syntax($lhs)));
    })
    |> Vec\map($$, $expr ==> {
      $lhs = $get_lhs($expr);
      return LintError::createWithPatches(
        $script,
        $pragma_map,
        $lhs,
        $linter,
        'Assigning to an empty list(), tuple(), or shape() is a noop. '.
        'Discard the value using `$_ = ...` instead.',
        Pha\patches(
          $script,
          Pha\patch_node($lhs, '$_', shape('trivia' => Pha\RetainTrivia::BOTH)),
        ),
      );
    });
}
