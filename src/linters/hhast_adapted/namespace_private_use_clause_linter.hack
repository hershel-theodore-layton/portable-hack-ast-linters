/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

/**
 * This linter is but one part of namespace_private_linter.
 * It detects use clauses that access foreign `_Private` (or `__Private`)
 * namespaces, but will not scan the expressions / statements for references
 * formed with qualified names.
 *
 * ```
 * namespace A\AThing;
 * use namespace A\Something\_Private; // << allowed
 * use namespace B\_Private; // << lint error
 *
 * const int X = B\_Private\X; // << Ignored
 * const int FROM_C = _Private\X; // << Ignored
 * ```
 */
function namespace_private_use_clause_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  // If you have multiple namespaces per file, "why else use namespace blocks?",
  // this linter will ignore this file. I won't object to a PR that adds this support.
  if (
    C\any(Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_BODY))
  ) {
    return vec[];
  }

  $is_name = Pha\create_token_matcher($script, Pha\KIND_NAME);

  $get_namespace_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_NAME);

  $current_namespace = Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_DECLARATION_HEADER,
  )
    |> C\first($$); // C\only() does not exist, and C\onlyx() would throw for 0.

  if ($current_namespace is null) {
    $namespace_prefix = '';
  } else {
    $name = Pha\as_syntax($current_namespace) |> $get_namespace_name($$);

    if ($is_name($name)) {
      $namespace_prefix =
        Pha\as_token($name) |> Pha\token_get_text($script, $$);
    } else {
      $namespace_prefix = Pha\as_syntax($name)
        |> Pha\node_get_code_compressed($script, $$)
        |> Str\split($$, '\\')[0];
    }
  }

  return Support\get_flattened_namespace_uses(
    $script,
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_USE_DECLARATION,
    ),
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
    ),
  )
    |> Vec\flatten($$)
    |> Vec\filter($$, $v ==> {
      list(, $use_text) = $v;
      $public_and_private_part = Str\split($use_text, '\\__Private', 2)
        |> C\count($$) !== 1 ? $$ : Str\split(C\onlyx($$), '\\_Private', 2);
      return C\count($public_and_private_part) > 1 &&
        !Str\starts_with($public_and_private_part[0], $namespace_prefix);
    })
    |> Vec\map(
      $$,
      $v ==> new LintError(
        $script,
        $v[0],
        $linter,
        'This use declaration includes a private namespace. '.
        'This namespace does not share a common prefix with your current namespace.',
      ),
    );
}
