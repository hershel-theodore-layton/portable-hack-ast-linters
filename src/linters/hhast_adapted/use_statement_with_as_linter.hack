/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function use_statement_with_as_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_missing = Pha\create_syntax_matcher($script, Pha\KIND_MISSING);

  $get_as = Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_AS);
  $has_as = $n ==> $get_as($n) |> !$is_missing($$);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_USE_CLAUSE)
    |> Vec\filter($$, $has_as)
    |> Vec\map(
      $$,
      $n ==> LintError::create(
        $script,
        $pragma_map,
        $n,
        $linter,
        'Use statements may not use the `as` keyword.',
      ),
    );
}
