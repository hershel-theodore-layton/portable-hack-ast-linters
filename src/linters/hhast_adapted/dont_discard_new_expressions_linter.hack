/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function dont_discard_new_expressions_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_object_creation_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_OBJECT_CREATION_EXPRESSION);

  $get_expression = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_EXPRESSION_STATEMENT_EXPRESSION,
  );

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_EXPRESSION_STATEMENT)
    |> Vec\filter(
      $$,
      $e ==> $get_expression($e) |> $is_object_creation_expression($$),
    )
    |> Vec\map(
      $$,
      $stmt ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $stmt,
        $linter,
        'You are ignoring the new object. Please use it or assign it to `$_`.',
        Pha\patches($script, Pha\patch_node(
          $stmt,
          '$_ = '.
          Pha\node_get_code_without_leading_or_trailing_trivia($script, $stmt),
          shape('trivia' => Pha\RetainTrivia::BOTH),
        )),
      ),
    );
}
