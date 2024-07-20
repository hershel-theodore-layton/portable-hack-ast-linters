/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function concat_merge_or_union_expression_can_be_simplified_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $resolver,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_argument_list =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST)
    |> Pha\returns_syntax($$);
  $get_call_receiver =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CALL_RECEIVER);

  $resolve_function_name = $call ==> $get_call_receiver($call)
    |> Pha\resolve_name($resolver, $script, $$);

  $is_decorated_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_DECORATED_EXPRESSION);

  $is_concat_merge_or_union = $call ==> $resolve_function_name($call)
    |> $$ === 'HH\Lib\Dict\merge' ||
      $$ === 'HH\Lib\Keyset\union' ||
      $$ === 'HH\Lib\Vec\concat';

  $simplified_call = dict[
    'HH\Lib\Dict\merge' => 'dict',
    'HH\Lib\Keyset\union' => 'keyset',
    'HH\Lib\Vec\concat' => 'vec',
  ];

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
  )
    |> Vec\filter($$, $call ==> {
      if (!$is_concat_merge_or_union($call)) {
        return false;
      }

      return $get_argument_list($call)
        |> Pha\list_get_items_of_children($script, $$)
        |> C\count($$) === 1 && !$is_decorated_expression($$[0]);
    })
    |> Vec\map(
      $$,
      $call ==> $resolve_function_name($call)
        |> LintError::createWithPatches(
          $script,
          $pragma_map,
          $call,
          $linter,
          Str\format(
            'This call to %s(...) can be simplified to %s(...). '.
            'If the type of the first argument is already %s, '.
            'you do not need to call any function.',
            $$,
            $simplified_call[$$],
            $simplified_call[$$],
          ),
          Pha\patches(
            $script,
            Pha\patch_node(
              $get_call_receiver($call),
              $simplified_call[$$],
              shape('trivia' => Pha\RetainTrivia::BOTH),
            ),
          ),
        ),
    );
}
