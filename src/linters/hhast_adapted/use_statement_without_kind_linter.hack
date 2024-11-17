/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function use_statement_without_kind_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_kind = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  );

  $kind_is_missing = $use_clause ==>
    $get_kind($use_clause) |> Pha\is_missing($$);

  return Vec\concat(
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_USE_DECLARATION,
    ),
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
    ),
  )
    |> Vec\filter($$, $kind_is_missing)
    |> Vec\map(
      $$,
      $n ==> LintError::createWithoutPatches(
        $script,
        $pragma_map,
        $n,
        $linter,
        'Must use namespace kind (`type` or `namespace`).',
      ),
    );
}
