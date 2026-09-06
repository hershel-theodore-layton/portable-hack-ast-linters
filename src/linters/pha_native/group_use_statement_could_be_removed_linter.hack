/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function group_use_statement_could_be_removed_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_clauses =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_CLAUSES);

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  )
    |> Vec\filter($$, $use ==> Pha\is_missing($get_clauses($use)))
    |> Vec\map(
      $$,
      $use ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $use,
        $linter,
        'This group use statement has no clauses and is a noop. Remove it.',
        Pha\patches(
          $script,
          Pha\patch_node($use, '', shape('trivia' => Pha\RetainTrivia::BOTH)),
        ),
      ),
    );
}
