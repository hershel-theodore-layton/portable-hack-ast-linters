/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Dict, Math, Str, Vec};
use namespace HTL\Pha;

type TUnusedVariableLinterAfterShadowing = shape(
  'is_assignment' => bool,
  'owners' => vec<Pha\Syntax>,
  'var' => Pha\Token,
  'var_name' => string,
);

type TUnusedVariableLinterUsage = shape(
  'is_assignment' => bool,
  'param_of_func' => Pha\NillableSyntax,
  'param_of_lambda' => Pha\NillableSyntax,
  'scopes' => vec<Pha\Syntax>,
  'var' => Pha\Token,
  'var_name' => string,
);

// This linter implements unused_variable_linter.
//
// It also doubles as unused_parameter_linter.
// It also triples as unused_lambda_parameter_linter.
//
// These linters are all variations on a theme.
function unused_variable_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $build_matcher = ($first, ...$rest) ==>
    Pha\create_syntax_matcher($script, $first, ...$rest);

  $is_abstract = Pha\create_token_matcher($script, Pha\KIND_ABSTRACT);
  $is_assignment_operator = Support\assignment_operator_matcher($script);
  $is_binary_expression = $build_matcher(Pha\KIND_BINARY_EXPRESSION);
  $is_class = Pha\create_token_matcher($script, Pha\KIND_CLASS);
  $is_classish_declaration = $build_matcher(Pha\KIND_CLASSISH_DECLARATION);
  $is_decl_header = $build_matcher(Pha\KIND_FUNCTION_DECLARATION_HEADER);
  $is_foreach = $build_matcher(Pha\KIND_FOREACH_STATEMENT);
  $is_lambda = $build_matcher(Pha\KIND_LAMBDA_EXPRESSION);
  $is_lambda_signature = $build_matcher(Pha\KIND_LAMBDA_SIGNATURE);
  $is_list_expression = $build_matcher(Pha\KIND_LIST_EXPRESSION);
  $is_member_selection_expression =
    $build_matcher(Pha\KIND_MEMBER_SELECTION_EXPRESSION);
  $is_methodish_declaration = $build_matcher(Pha\KIND_METHODISH_DECLARATION);
  $is_parameter_declaration = $build_matcher(Pha\KIND_PARAMETER_DECLARATION);
  $is_scope = $build_matcher(
    Pha\KIND_FUNCTION_DECLARATION,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_METHODISH_DECLARATION,
  );

  $get_binop_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_BINARY_OPERATOR);
  $get_class_keyword =
    Pha\create_member_accessor($script, Pha\MEMBER_CLASSISH_KEYWORD);
  $get_foreach_key =
    Pha\create_member_accessor($script, Pha\MEMBER_FOREACH_KEY);
  $get_foreach_value =
    Pha\create_member_accessor($script, Pha\MEMBER_FOREACH_VALUE);
  $get_method_decl_header = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
  );
  $get_func_decl_header_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_MODIFIERS);
  $get_lambda_signature =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_SIGNATURE);
  $get_list_expr_members =
    Pha\create_member_accessor($script, Pha\MEMBER_LIST_MEMBERS);
  $get_parameter_visibility =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_VISIBILITY);

  $is_assignment_expression = $node ==> $is_binary_expression($node) &&
    $is_assignment_operator($get_binop_operator($node) |> Pha\as_token($$));

  $is_promoted_contructor_parameter = (Pha\Token $token) ==>
    Pha\node_get_syntax_ancestors($script, $token)
    |> C\find($$, $is_parameter_declaration)
    |> $$ is nonnull && Pha\is_token($get_parameter_visibility($$));

  // Assignments to members are not local to the function.
  // This assignment should be classified as a use of `$v`: `$v->prop = 0`.
  $assignment_has_non_local_effects = (
    Pha\Syntax $assignment,
    Pha\Token $var,
  ) ==> Pha\node_get_syntax_ancestors($script, $var)
    |> Support\vec_take_while_incl_true($$, $node ==> $node === $assignment)
    |> C\any($$, $is_member_selection_expression);

  $classify_use = ($variable): ?TUnusedVariableLinterUsage ==> {
    $ret = shape(
      'is_assignment' => false,
      'param_of_func' => Pha\NIL,
      'param_of_lambda' => Pha\NIL,
      'scopes' => vec[],
      'var' => $variable,
      'var_name' => Pha\token_get_text($script, $variable),
    );

    $assigns_to_var_local = ($loop_node): bool ==> $is_foreach($loop_node) &&
      (
        $get_foreach_key($loop_node) === $variable ||
        $get_foreach_value($loop_node) === $variable
      ) ||
      (
        $is_assignment_expression($loop_node) &&
        Support\get_first_token($script, $loop_node) === $variable &&
        !$assignment_has_non_local_effects($loop_node, $variable)
      ) ||
      (
        $is_list_expression($loop_node) &&
        // Only mark `$a` and `$c` as assigned: `$list($a[$b], $c)`
        C\any(
          $get_list_expr_members($loop_node)
            |> Pha\node_get_children($script, $$),
          $mem ==> Support\get_first_token($script, $mem) === $variable,
        )
      );

    foreach (Pha\node_get_syntax_ancestors($script, $variable) as $node) {
      if ($assigns_to_var_local($node)) {
        $ret['is_assignment'] = true;
      } else if ($is_decl_header($node)) {
        // Very uncommon, let's ignore it. Nasty oversight
        // `function foo((function(int): int) $lambda = $a ==> $a)`.
        if (!C\is_empty($ret['scopes'])) {
          return null;
        }
        $ret['param_of_func'] = $node;
      } else if ($is_lambda_signature($node)) {
        $ret['param_of_lambda'] = Pha\syntax_get_parent($script, $node);
      } else if (
        $is_lambda($node) && $get_lambda_signature($node) === $variable
      ) {
        $ret['param_of_lambda'] = $node;
      }

      if ($is_scope($node)) {
        $ret['scopes'][] = $node;
      }
    }

    return C\is_empty($ret['scopes']) ? null : $ret;
  };

  $apply_shadowing_rules = (
    vec<TUnusedVariableLinterUsage> $usages,
  ): vec<TUnusedVariableLinterAfterShadowing> ==> {
    $lambda_params =
      Vec\filter($usages, $u ==> $u['param_of_lambda'] !== Pha\NIL)
      |> Vec\map(
        $$,
        $u ==> shape(
          'lambda' => Pha\as_nonnil($u['param_of_lambda']),
          'var_name' => $u['var_name'],
        ),
      )
      // Sorting by index DESC, so inner lambdas appear before outer lambdas.
      // `$x ==> $x ==> $x + $y`, where the outer $x is shadowed by the second $x.
      // The outer $x goes unused and should probably have been $y.
      // The above expression closes over a $y in function scope.
      |> Vec\sort_by($$, $u ==> -Pha\node_get_source_order($u['lambda']));

    return Vec\map(
      $usages,
      $u ==> shape(
        'is_assignment' => $u['is_assignment'] ||
          $u['param_of_func'] !== Pha\NIL ||
          $u['param_of_lambda'] !== Pha\NIL,
        'owners' => C\find(
          $lambda_params,
          $l ==> $l['var_name'] === $u['var_name'] &&
            C\contains(
              Pha\node_get_ancestors($script, $u['var']),
              $l['lambda'],
            ),
        )
          |> Shapes::idx($$, 'lambda')
          |> $$ is null ? $u['scopes'] : vec[$$],
        'var' => $u['var'],
        'var_name' => $u['var_name'],
      ),
    );
  };

  $is_abstract_scope = $owner ==> {
    if (!$is_methodish_declaration($owner)) {
      return false;
    }

    $classish = Pha\node_get_syntax_ancestors($script, $owner)
      |> C\findx($$, $is_classish_declaration);

    return !$is_class($get_class_keyword($classish)) ||
      C\any(
        $get_method_decl_header($owner)
          |> Pha\as_syntax($$)
          |> $get_func_decl_header_modifiers($$)
          |> Pha\node_get_children($script, $$),
        $is_abstract,
      );
  };

  list($assignments, $usages) =
    Pha\index_get_nodes_by_kind($token_index, Pha\KIND_VARIABLE_TOKEN)
    |> Vec\map($$, $classify_use)
    |> Vec\filter_nulls($$)
    |> Vec\filter($$, $u ==> $u['var_name'] !== '$this')
    |> $apply_shadowing_rules($$)
    |> Vec\partition($$, $u ==> $u['is_assignment']);

  $usages_by_name = Dict\group_by($usages, $u ==> $u['var_name']);

  $is_unused = (TUnusedVariableLinterAfterShadowing $a) ==>
    !Str\starts_with($a['var_name'], '$_') &&
    !$is_promoted_contructor_parameter($a['var']) &&
    !C\any($a['owners'], $is_abstract_scope) &&
    !C\any(
      idx($usages_by_name, $a['var_name'], vec[]),
      $u ==> C\contains(
        $u['owners'],
        // Picking the maximum owner (the inmost lambda), because of this code:
        // $b = 4;
        // () ==> { $b = 5; } // << This $b assignment is unused.
        // use_of($b);
        Math\max_by($a['owners'], Pha\node_get_source_order<>),
      ),
    );

  return Vec\filter($assignments, $is_unused)
    |> Vec\map(
      $$,
      $a ==>
        new LintError($script, $a['var'], $linter, 'This variable is unused.'),
    );
}
