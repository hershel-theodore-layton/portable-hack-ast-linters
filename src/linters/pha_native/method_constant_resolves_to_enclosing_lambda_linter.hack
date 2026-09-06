/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function method_constant_resolves_to_enclosing_lambda_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $consts = keyset[
    '__FUNCTION__',
    '__METHOD__',
    '__FUNCTION_CREDENTIAL__',
  ];
  $is_lambda = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_LAMBDA_EXPRESSION,
    Pha\KIND_ANONYMOUS_FUNCTION,
    Pha\KIND_AWAITABLE_CREATION_EXPRESSION,
  );
  $is_member_selection = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_SCOPE_RESOLUTION_EXPRESSION,
    Pha\KIND_MEMBER_SELECTION_EXPRESSION,
    Pha\KIND_SAFE_MEMBER_SELECTION_EXPRESSION,
  );

  $is_qualified_name =
    Pha\create_syntax_matcher($script, Pha\KIND_QUALIFIED_NAME);
  $get_member_name = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_SCOPE_RESOLUTION_NAME,
    Pha\MEMBER_MEMBER_NAME,
    Pha\MEMBER_SAFE_MEMBER_NAME,
  );

  return Pha\index_get_nodes_by_kind($token_index, Pha\KIND_NAME)
    |> Vec\filter(
      $$,
      $token ==> C\contains_key($consts, Pha\token_get_text($script, $token)),
    )
    |> Vec\filter($$, $token ==> {
      $ancestors = Pha\node_get_syntax_ancestors($script, $token);
      $parent = C\firstx($ancestors);
      if (
        C\any($ancestors, $is_qualified_name) ||
        ($is_member_selection($parent) && $get_member_name($parent) === $token)
      ) {
        return false;
      }

      return C\any($ancestors, $is_lambda);
    })
    |> Vec\map(
      $$,
      $token ==> LintError::createWithoutPatches(
        $script,
        $pragma_map,
        $token,
        $linter,
        Str\format(
          '%s refers to the operator() of the lambda, not to your function. '.
          'Hoist the constant and capture it by value.',
          Pha\token_get_text($script, $token),
        ),
      ),
    );
}
