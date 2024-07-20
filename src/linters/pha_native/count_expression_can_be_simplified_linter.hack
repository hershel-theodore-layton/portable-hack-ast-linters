/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function count_expression_can_be_simplified_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $resolver,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_binop = Pha\create_syntax_matcher($script, Pha\KIND_BINARY_EXPRESSION);
  $is_equality = Pha\create_token_matcher(
    $script,
    Pha\KIND_EQUAL_EQUAL,
    Pha\KIND_EQUAL_EQUAL_EQUAL,
  );
  $is_exclamation = Pha\create_token_matcher($script, Pha\KIND_EXCLAMATION);
  $is_greater_than = Pha\create_token_matcher($script, Pha\KIND_GREATER_THAN);
  $is_greater_than_or_equal =
    Pha\create_token_matcher($script, Pha\KIND_GREATER_THAN_EQUAL);
  $is_inequality = Pha\create_token_matcher(
    $script,
    Pha\KIND_EXCLAMATION_EQUAL,
    Pha\KIND_EXCLAMATION_EQUAL_EQUAL,
  );
  $is_less_than = Pha\create_token_matcher($script, Pha\KIND_LESS_THAN);
  $is_less_than_or_greater =
    Pha\create_token_matcher($script, Pha\KIND_LESS_THAN_EQUAL);
  $is_prefix_unary_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_PREFIX_UNARY_EXPRESSION);

  $get_argument_list =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST);
  $get_binop_lhs =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_LEFT_OPERAND);
  $get_binop_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);
  $get_binop_rhs =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_RIGHT_OPERAND);
  $get_call_receiver =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);
  $get_prefix_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_PREFIX_UNARY_OPERATOR);

  $is_c_count = $call ==> $get_call_receiver($call)
    |> Pha\resolve_name($resolver, $script, $$) === 'HH\Lib\C\count';

  $is_logical_not = $n ==> $is_prefix_unary_expression($n) &&
    $is_exclamation($get_prefix_operator($n));

  $classify_cmp_kind = $n ==> {
    if ($is_equality($n)) {
      return Support\ComparisonKind::EQUALS;
    }
    if ($is_inequality($n)) {
      return Support\ComparisonKind::NOT_EQUALS;
    }
    if ($is_less_than($n)) {
      return Support\ComparisonKind::LESS_THAN;
    }
    if ($is_less_than_or_greater($n)) {
      return Support\ComparisonKind::LESS_THAN_OR_EQUAL;
    }
    if ($is_greater_than($n)) {
      return Support\ComparisonKind::GREATER_THAN;
    }
    if ($is_greater_than_or_equal($n)) {
      return Support\ComparisonKind::GREATER_THAN_OR_EQUAL;
    }
    return null;
  };

  $get_error = ($parent, $call) ==> {
    $replace_with = $function_name ==> Pha\patches($script, Pha\patch_node(
      $parent,
      Str\format(
        '%s(%s)',
        $function_name,
        Pha\node_get_code($script, $get_argument_list($call)),
      ),
      shape('trivia' => Pha\RetainTrivia::BOTH),
    ));

    if ($is_logical_not($parent)) {
      return tuple(
        '!C\count(...) is equivalent to C\is_empty(...)',
        $replace_with('C\\is_empty'),
      );
    }

    if (!$is_binop($parent)) {
      return tuple('', null);
    }

    $cmp_kind = $classify_cmp_kind($get_binop_operator($parent));

    if ($cmp_kind is null) {
      return tuple('', null);
    }

    // Need this because of yoda conditions `0 === C\count(...)`.
    // In Hack, `C\count(...) === 0` is canonical.
    $is_canonical = $get_binop_lhs($parent) === $call;
    $cmp = $is_canonical ? $get_binop_rhs($parent) : $get_binop_lhs($parent)
      |> Pha\node_get_code_compressed($script, $$);

    if (!$is_canonical) {
      switch ($cmp_kind) {
        case Support\ComparisonKind::EQUALS:
        case Support\ComparisonKind::NOT_EQUALS:
          break;
        case Support\ComparisonKind::LESS_THAN:
          $cmp_kind = Support\ComparisonKind::GREATER_THAN;
          break;
        case Support\ComparisonKind::LESS_THAN_OR_EQUAL:
          $cmp_kind = Support\ComparisonKind::GREATER_THAN_OR_EQUAL;
          break;
        case Support\ComparisonKind::GREATER_THAN:
          $cmp_kind = Support\ComparisonKind::LESS_THAN;
          break;
        case Support\ComparisonKind::GREATER_THAN_OR_EQUAL:
          $cmp_kind = Support\ComparisonKind::LESS_THAN_OR_EQUAL;
      }
    }

    if ($cmp === '0') {
      switch ($cmp_kind) {
        case Support\ComparisonKind::EQUALS:
          return tuple(
            'C\count(...) === 0 is equivalent to C\is_empty(...)',
            $replace_with('C\\is_empty'),
          );

        case Support\ComparisonKind::NOT_EQUALS:
          return tuple(
            'C\count(...) !== 0 is equivalent to !C\is_empty(...)',
            $replace_with('!C\\is_empty'),
          );
        case Support\ComparisonKind::LESS_THAN:
          return tuple(
            'C\count(...) < 0 is always false, counts are never negative',
            null,
          );
        case Support\ComparisonKind::LESS_THAN_OR_EQUAL:
          return tuple(
            'C\count(...) <= 0 is equivalent to C\is_empty(...)',
            $replace_with('C\\is_empty'),
          );
        case Support\ComparisonKind::GREATER_THAN:
          return tuple(
            'C\count(...) > 0 is equivalent to !C\is_empty(...)',
            $replace_with('!C\\is_empty'),
          );
        case Support\ComparisonKind::GREATER_THAN_OR_EQUAL:
          return tuple(
            'C\count(...) >= 0 is always true, counts are never negative',
            null,
          );
      }
    }

    if ($cmp !== '1') {
      return tuple('', null);
    }

    switch ($cmp_kind) {
      case Support\ComparisonKind::EQUALS:
      case Support\ComparisonKind::NOT_EQUALS:
        return tuple('', null);
      case Support\ComparisonKind::LESS_THAN:
        return tuple(
          'C\count(...) < 1 is equivalent to C\is_empty(...)',
          $replace_with('C\\is_empty'),
        );
      case Support\ComparisonKind::LESS_THAN_OR_EQUAL:
      case Support\ComparisonKind::GREATER_THAN:
        return tuple('', null);
      case Support\ComparisonKind::GREATER_THAN_OR_EQUAL:
        return tuple(
          'C\count(...) >= 1 is equivalent to !C\is_empty(...)',
          $replace_with('!C\\is_empty'),
        );
    }
  };

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
  )
    |> Vec\filter($$, $is_c_count)
    |> Vec\map(
      $$,
      $c ==> Pha\syntax_get_parent($script, $c)
        |> shape('node' => $$, 'error' => $get_error($$, $c)),
    )
    |> Vec\filter($$, $e ==> $e['error'][0] !== '')
    |> Vec\map(
      $$,
      $e ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $e['node'],
        $linter,
        Str\format('This expression can be simplified, %s.', $e['error'][0]),
        $e['error'][1],
      ),
    );
}
