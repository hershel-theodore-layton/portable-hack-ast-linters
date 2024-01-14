/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Keyset, Vec};
use namespace HTL\Pha;

function unused_use_clause_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $token_index,
  Pha\Resolver $resolver,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $used_clauses = Pha\index_get_nodes_by_kind($token_index, Pha\KIND_NAME)
    |> Vec\map(
      $$,
      $n ==> Pha\resolve_name_and_use_clause($resolver, $script, $n)[1],
    )
    |> Vec\filter($$, $c ==> $c !== Pha\NIL)
    |> Vec\map($$, Pha\as_syntax<>)
    |> Keyset\map($$, Pha\node_get_id<>);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_USE_CLAUSE)
    |> Vec\filter(
      $$,
      $c ==> !C\contains_key($used_clauses, Pha\node_get_id($c)),
    )
    |> Vec\map(
      $$,
      $c ==> LintError::create(
        $script,
        $pragma_map,
        $c,
        $linter,
        'This use clause is not used.',
      ),
    );
}
