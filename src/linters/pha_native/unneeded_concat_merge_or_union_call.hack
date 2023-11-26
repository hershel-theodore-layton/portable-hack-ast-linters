/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function unneeded_concat_merge_or_union_call(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $resolver,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_argument_list =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST);
  $get_call_receiver =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);

  $resolve_function_name = $call ==> $get_call_receiver($call)
    |> Pha\resolve_name(
      $resolver,
      $$,
      Pha\node_get_code_compressed($script, $$),
    );

  $is_concat_merge_or_union = $call ==> $resolve_function_name($call)
    |> $$ === 'HH\Lib\Dict\merge' ||
      $$ === 'HH\Lib\Keyset\union' ||
      $$ === 'HH\Lib\Vec\concat';

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
  )
    |> Vec\filter($$, $call ==> {
      if (!$is_concat_merge_or_union($call)) {
        return false;
      }

      return $get_argument_list($call)
        |> Pha\list_get_items_of_children($script, Pha\as_syntax($$))
        |> C\count($$) === 1;
    })
    |> Vec\map(
      $$,
      $call ==> new LintError(
        $script,
        $call,
        $linter,
        Str\format(
          'A call to %s(...) with a single argument is unneeded. '.
          'You may replace the call with its first argument.',
          $resolve_function_name($call),
        ),
      ),
    );
}
