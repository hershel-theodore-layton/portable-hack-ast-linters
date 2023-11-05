/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function dont_discard_new_expressions_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_object_creation_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_OBJECT_CREATION_EXPRESSION);

  $get_expression = Pha\create_member_accessor($script, dict[
    Pha\KIND_EXPRESSION_STATEMENT => Pha\MEMBER_EXPRESSION_STATEMENT_EXPRESSION,
  ]);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_EXPRESSION_STATEMENT)
    |> Vec\filter(
      $$,
      $e ==> $get_expression($e) |> $is_object_creation_expression($$),
    )
    |> Vec\map(
      $$,
      $stmt ==> new LintError(
        $script,
        $stmt,
        $linter,
        'You are ignoring the new object. Please use it or assign it to `$_`.',
      ),
    );
}
