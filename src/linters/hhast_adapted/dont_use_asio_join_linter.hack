/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function dont_use_asio_join_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $resolver,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_qualified_name =
    Pha\create_syntax_matcher($script, Pha\KIND_QUALIFIED_NAME);

  return Pha\index_get_nodes_by_kind($token_index, Pha\KIND_NAME)
    |> Vec\map(
      $$,
      $n ==>
        C\find(Pha\node_get_ancestors($script, $n), $is_qualified_name) ?? $n,
    )
    |> Vec\unique_by($$, Pha\node_get_id<>)
    |> Vec\filter(
      $$,
      $n ==>
        Pha\resolve_name($resolver, $script, $n) |> $$ === 'HH\\Asio\\join',
    )
    |> Vec\map(
      $$,
      $n ==> LintError::create(
        $script,
        $pragma_map,
        $n,
        $linter,
        "Don't use Asio\join().",
      ),
    );
}
