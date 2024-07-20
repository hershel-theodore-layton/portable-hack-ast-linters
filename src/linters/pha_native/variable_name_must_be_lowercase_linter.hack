/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function variable_name_must_be_lowercase_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_methodish_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_METHODISH_DECLARATION);
  $is_property_declarator =
    Pha\create_syntax_matcher($script, Pha\KIND_PROPERTY_DECLARATOR);
  $is_scope_resolution_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_SCOPE_RESOLUTION_EXPRESSION);

  $get_methodish_declaration_header = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
  )
    |> Pha\returns_syntax($$);
  $get_parameter_list =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_PARAMETER_LIST)
    |> Pha\returns_syntax($$);
  $get_parameter_name =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_NAME)
    |> Pha\returns_token($$);
  $get_parameter_visibility =
    Pha\create_member_accessor($script, Pha\MEMBER_PARAMETER_VISIBILITY);

  return Pha\index_get_nodes_by_kind($token_index, Pha\KIND_VARIABLE_TOKEN)
    |> Vec\filter($$, $var ==> {
      $var_name = Pha\token_get_text($script, $var);
      if ($var_name === Str\lowercase($var_name)) {
        return false;
      }

      $parent = Pha\token_get_parent($script, $var);

      if (
        $is_property_declarator($parent) ||
        $is_scope_resolution_expression($parent) &&
          Pha\node_get_last_childx($script, $parent) === $var
      ) {
        return false;
      }

      $method_decl = Pha\node_get_syntax_ancestors($script, $var)
        |> C\find($$, $is_methodish_declaration);

      if ($method_decl is null) {
        return true;
      }

      // __construct(private typename $camelCase) { validate($camelCase); }
      return $get_methodish_declaration_header($method_decl)
        |> $get_parameter_list($$)
        |> Pha\list_get_items_of_children($script, $$)
        |> !C\any($$, $param ==> {
          $param = Pha\as_syntax($param);
          $param_name =
            $get_parameter_name($param) |> Pha\token_get_text($script, $$);
          return $param_name === $var_name &&
            !Pha\is_missing($get_parameter_visibility($param));
        });
    })
    |> Vec\map(
      $$,
      $var ==> LintError::create(
        $script,
        $pragma_map,
        $var,
        $linter,
        'Local variables should be $snake_case and may therefore not contain uppercase letters.',
      ),
    );
}
