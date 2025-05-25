/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function lambda_parameter_list_parentheses_can_be_removed_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_decorated_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_DECORATED_EXPRESSION);
  $is_dot_dot_dot = Pha\create_token_matcher($script, Pha\KIND_DOT_DOT_DOT);

  $get_colon = Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_COLON);
  $get_contexts =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_CONTEXTS);
  $get_parameters =
    Pha\create_member_accessor($script, Pha\MEMBER_LAMBDA_PARAMETERS)
    |> Pha\returns_syntax($$);

  $get_parameter_attribute =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_ATTRIBUTE);
  $get_parameter_call_conv =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_CALL_CONVENTION);
  $get_parameter_default_value =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_DEFAULT_VALUE);
  $get_parameter_name =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_NAME);
  $get_parameter_readonly =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_READONLY);
  $get_parameter_type =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_TYPE);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_LAMBDA_SIGNATURE)
    |> Vec\filter($$, $sig ==> {
      $params = $get_parameters($sig)
        |> Pha\list_get_items_of_children($script, $$);

      if (C\count($params) !== 1) {
        return false;
      }

      $param = Pha\as_syntax($params[0]);

      if (
        C\any(
          vec[
            $get_parameter_attribute,
            $get_parameter_call_conv,
            $get_parameter_default_value,
            $get_parameter_readonly,
            $get_parameter_type,
          ],
          $getter ==> !Pha\is_missing($getter($param)),
        )
      ) {
        return false;
      }

      if ($get_parameter_name($param) |> $is_decorated_expression($$)) {
        return false;
      }

      if (
        $get_parameter_name($param)
        |> Support\get_last_token($script, $$)
        |> Support\get_previous_token($script, $$)
        |> $is_dot_dot_dot($$)
      ) {
        return false;
      }

      return
        Pha\is_missing($get_colon($sig)) && Pha\is_missing($get_contexts($sig));
    })
    |> Vec\map(
      $$,
      $sig ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $sig,
        $linter,
        'The parentheses around this lambda parameter are redundant and can be removed.',
        Pha\patches($script, Pha\patch_node(
          $sig,
          $get_parameters($sig)
            |> Pha\list_get_items_of_children($script, $$)[0]
            |> Pha\node_get_code($script, $$),
          shape('trivia' => Pha\RetainTrivia::BOTH),
        )),
      ),
    );
}
