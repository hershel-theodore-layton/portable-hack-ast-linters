/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function use_statement_without_kind_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_missing = Pha\create_syntax_matcher($script, Pha\KIND_MISSING);

  $get_kind = Pha\create_member_accessor($script, dict[
    Pha\KIND_NAMESPACE_USE_DECLARATION => Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION =>
      Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  ]);

  $kind_is_missing = ($use_clause) ==>
    $get_kind($use_clause) |> $is_missing($$);

  return Vec\concat(
    Pha\script_get_nodes_by_kind(
      $script,
      $syntax_index,
      Pha\KIND_NAMESPACE_USE_DECLARATION,
    ),
    Pha\script_get_nodes_by_kind(
      $script,
      $syntax_index,
      Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
    ),
  )
    |> Vec\filter($$, $kind_is_missing)
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'Must use namespace kind (`type` or `namespace`).',
      ),
    );
}
