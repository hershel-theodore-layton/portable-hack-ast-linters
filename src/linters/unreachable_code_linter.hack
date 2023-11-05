/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function unreachable_code_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_syntax = $kind ==>
    Pha\script_get_nodes_by_kind($script, $syntax_index, $kind);
  $node_is_list = Pha\create_syntax_matcher($script, Pha\KIND_NODE_LIST);
  $creates_unreachable_code = $stmt ==> Pha\node_get_parent($script, $stmt)
    |> $node_is_list($$) && Pha\node_get_last_child($script, $$) !== $stmt;

  return Vec\concat(
    $get_syntax(Pha\KIND_BREAK_STATEMENT),
    $get_syntax(Pha\KIND_CONTINUE_STATEMENT),
    $get_syntax(Pha\KIND_RETURN_STATEMENT),
    $get_syntax(Pha\KIND_THROW_STATEMENT),
  )
    |> Vec\filter($$, $creates_unreachable_code)
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'The code after this statement is unreachable.',
      ),
    );
}
