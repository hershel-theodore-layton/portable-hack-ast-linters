/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function dont_use_asio_join_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $resolver,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_function_call_receiver =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
  )
    |> Vec\filter(
      $$,
      $n ==> $get_function_call_receiver($n)
        |> Pha\resolve_name($resolver, $script, $$)
        |> $$ === 'HH\\Asio\\join',
    )
    |> Vec\map(
      $$,
      $n ==> new LintError($script, $n, $linter, "Don't use Asio\join()."),
    );
}
