/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function dont_create_forwarding_lambdas_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  shape(?'no_error_for_lambdas_with_typed_parameters_or_return' => bool)
    $options = shape(),
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $ignore_typed_lambdas =
    $options['no_error_for_lambdas_with_typed_parameters_or_return'] ?? false;

  $is_await = Pha\create_token_matcher($script, Pha\KIND_AWAIT);
  $is_decorated_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_DECORATED_EXPRESSION);
  $is_dot_dot_dot = Pha\create_token_matcher($script, Pha\KIND_DOT_DOT_DOT);
  $is_function_call_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_FUNCTION_CALL_EXPRESSION);
  $is_inout = Pha\create_token_matcher($script, Pha\KIND_INOUT);
  $is_missing = Pha\create_syntax_matcher($script, Pha\KIND_MISSING);
  $is_name_or_var = Pha\create_matcher(
    $script,
    vec[Pha\KIND_QUALIFIED_NAME, Pha\KIND_VARIABLE_SYNTAX],
    vec[Pha\KIND_NAME],
    vec[],
  );
  $is_parent_or_self =
    Pha\create_token_matcher($script, Pha\KIND_SELF, Pha\KIND_PARENT);
  $is_prefix_unary_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_PREFIX_UNARY_EXPRESSION);
  $is_scope_resolution_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_SCOPE_RESOLUTION_EXPRESSION);
  $is_variable_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_VARIABLE_SYNTAX);

  $get_argument_list =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST);
  $get_function_receiver =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);
  $get_lambda_async =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_ASYNC);
  $get_lambda_body =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_BODY);
  $get_lambda_parameters =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_PARAMETERS);
  $get_lambda_return_type =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_TYPE);
  $get_lambda_signature =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_SIGNATURE);
  $get_parameter_call_convention =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_CALL_CONVENTION);
  $get_parameter_default_value =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_DEFAULT_VALUE);
  $get_parameter_name =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_NAME);
  $get_parameter_type =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_TYPE);
  $get_unary_operator =
    Pha\create_member_accessor($script, Pha\MEMBER_PREFIX_UNARY_OPERATOR);
  $get_unary_operand =
    Pha\create_member_accessor($script, Pha\MEMBER_PREFIX_UNARY_OPERAND);
  $get_scope_resolution_qualifier =
    Pha\create_member_accessor($script, Pha\MEMBER_SCOPE_RESOLUTION_QUALIFIER);

  $is_typed_lambda = ($sig, $parameters) ==>
    C\any($parameters, $p ==> !$is_missing($get_parameter_type($p))) ||
    !$is_missing($get_lambda_return_type($sig));

  $convert_parameters = $parameters ==> Vec\map(
    $parameters,
    $p ==> shape(
      'name' => $get_parameter_name($p)
        |> Support\get_last_token($script, $$)
        |> Pha\token_get_text($script, $$),
      'call_conv' => $get_parameter_name($p)
        |> Support\get_first_token($script, $$)
        |> $is_dot_dot_dot($$)
          ? Support\CallingCovention::VARIADIC
          : (
              !$is_missing($get_parameter_call_convention($p))
                ? Support\CallingCovention::INOUT
                : Support\CallingCovention::PLAIN
            ),
      'has_default' => !$is_missing($get_parameter_default_value($p)),
    ),
  );

  $extract_qualifying_argument_list = $call ==> {
    if (!$is_function_call_expression($call)) {
      return Pha\NIL;
    }
    $call = Pha\as_syntax($call);

    $receiver = $get_function_receiver($call);
    if (
      $is_name_or_var($receiver) ||
      (
        $is_scope_resolution_expression($receiver) &&
        !$is_parent_or_self(
          Pha\as_syntax($receiver) |> $get_scope_resolution_qualifier($$),
        )
      )
    ) {
      return $get_argument_list($call) |> Pha\as_syntax($$);
    }

    return Pha\NIL;
  };

  $get_argument_list = ($lambda) ==> {
    $body = $get_lambda_body($lambda);

    if (!Pha\is_syntax($body)) {
      return Pha\NIL;
    }

    $body = Pha\as_syntax($body);

    if ($is_missing($get_lambda_async($lambda))) {
      return $extract_qualifying_argument_list($body);
    }

    if (
      !$is_prefix_unary_expression($body) ||
      !$is_await($get_unary_operator($body))
    ) {
      return Pha\NIL;
    }

    return $extract_qualifying_argument_list($get_unary_operand($body));
  };

  $get_parameters = $lambda ==> {
    $sig = $get_lambda_signature($lambda);

    if (Pha\is_token($sig)) {
      return vec[shape(
        'name' => Pha\token_get_text($script, Pha\as_token($sig)),
        'call_conv' => Support\CallingCovention::PLAIN,
        'has_default' => false,
      )];
    }

    $sig = Pha\as_syntax($sig);
    $parameters = $get_lambda_parameters($sig)
      |> Pha\as_syntax($$)
      |> Pha\list_get_items_of_children($script, $$)
      |> Vec\map($$, Pha\as_syntax<>);

    if ($ignore_typed_lambdas && $is_typed_lambda($sig, $parameters)) {
      return vec[shape(
        'name' => 'Lambda with typehint, okay. (Given a fake default param.)',
        'has_default' => true,
        'call_conv' => Support\CallingCovention::OTHER,
      )];
    }

    return $convert_parameters($parameters);
  };

  $get_arguments = ($argument_list) ==> Vec\map(
    Pha\list_get_items_of_children($script, $argument_list),
    $a ==> {
      $first_token = Support\get_first_token($script, $a);
      $call_conv = $is_decorated_expression($a)
        ? (
            $is_inout($first_token)
              ? Support\CallingCovention::INOUT
              : Support\CallingCovention::VARIADIC
          )
        : (
            $is_variable_expression($a)
              ? Support\CallingCovention::PLAIN
              : Support\CallingCovention::OTHER
          );

      return shape(
        'name' =>
          Pha\token_get_text($script, Support\get_last_token($script, $a)),
        'call_conv' => $call_conv,
      );
    },
  );

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_LAMBDA_EXPRESSION)
    |> Vec\filter($$, $lambda ==> {
      $argument_list = $get_argument_list($lambda);

      if ($argument_list === Pha\NIL) {
        return false;
      }

      $argument_list = Pha\as_nonnil($argument_list);
      $params = $get_parameters($lambda);

      if (
        C\any($params, $p ==> $p['has_default']) ||
        C\count(Pha\node_get_children($script, $argument_list)) !==
          C\count($params)
      ) {
        return false;
      }

      $args = $get_arguments(Pha\as_nonnil($argument_list));

      foreach ($args as $i => $a) {
        $p = $params[$i];
        if ($p['call_conv'] !== $a['call_conv'] || $p['name'] !== $a['name']) {
          return false;
        }
      }

      return true;
    })
    |> Vec\map(
      $$,
      $lambda ==> new LintError(
        $script,
        $lambda,
        $linter,
        'This lambda just forwards to the inner function. '.
        'Pass the inner function directly instead.',
      ),
    );
}
