/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function use_statement_with_leading_backslash_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $has_leading_backslash = $node ==> Pha\node_get_descendants($script, $node)
    |> C\find($$, Pha\is_token<>) ?? Pha\NIL
    |> Pha\token_get_text($script, Pha\as_token_or_nil($$)) === '\\';

  $get_prefix = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_NAME,
    Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX,
  );

  return Vec\concat(
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
    ),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_USE_CLAUSE),
  )
    |> Vec\map($$, $get_prefix)
    |> Vec\filter($$, $has_leading_backslash)
    |> Vec\map(
      $$,
      $n ==> LintError::create(
        $script,
        $pragma_map,
        Pha\node_get_parent($script, $n),
        $linter,
        'The leading backslashes in use declarations do not have an effect. '.
        'You may remove them.',
      ),
    );
}
