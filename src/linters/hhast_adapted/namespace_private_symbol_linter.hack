/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

/**
 * This linter complements namespace_private_use_clause_linter.
 * That linter gives an early notice if the namespace use declaration imports
 * something private from a namespace you don't share a prefix with.
 * This is still valuable for a quicker feedback loop.
 *
 * This linter does the heavy lifting and scans through the body of your code
 * to see if you are using qualified names to "outsmart" the first linter.
 */
function namespace_private_symbol_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $token_index,
  Pha\Resolver $resolver,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_namespace_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_NAMESPACE_DECLARATION);
  $is_qualified_name =
    Pha\create_syntax_matcher($script, Pha\KIND_QUALIFIED_NAME);

  $get_namespace_header =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_HEADER);
  $get_namespace_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_NAME);

  $main_namespace =
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_DECLARATION)
    |> C\first($$);

  return Pha\index_get_nodes_by_kind($token_index, Pha\KIND_NAME)
    |> Vec\map(
      $$,
      $n ==>
        C\find(Pha\node_get_ancestors($script, $n), $is_qualified_name) ?? $n,
    )
    |> Vec\unique_by($$, Pha\node_get_id<>)
    |> Vec\filter(
      $$,
      $n ==> {
        $name = Pha\resolve_name(
          $resolver,
          $n,
          Pha\node_get_code_compressed($script, $n),
        );

        $public_and_private_part = Str\split($name, '\\__Private', 2)
          |> C\count($$) !== 1 ? $$ : Str\split(C\onlyx($$), '\\_Private', 2);

        if (C\count($public_and_private_part) === 1) {
          return false;
        }

        $nearest_namespace = C\find(
          Pha\node_get_syntax_ancestors($script, $n),
          $is_namespace_declaration,
        ) ??
          $main_namespace;

        if ($nearest_namespace is null) {
          return true;
        }

        $namespace_prefix = $get_namespace_header($nearest_namespace)
          |> Pha\as_syntax($$)
          |> $get_namespace_name($$)
          |> Pha\resolve_name(
            $resolver,
            $$,
            Pha\node_get_code_compressed($script, $$),
          )
          |> Str\split($$, '\\')
          |> C\firstx($$);

        return !Str\starts_with($name, $namespace_prefix);
      },
    )
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'This constant/function/type comes from a private namespace. '.
        'This namespace does not share a common prefix with your current namespace.',
      ),
    );
}
