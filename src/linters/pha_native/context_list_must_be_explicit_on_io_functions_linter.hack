/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function context_list_must_be_explicit_on_io_functions_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_async = Pha\create_token_matcher($script, Pha\KIND_ASYNC);
  $is_await = Pha\create_token_matcher($script, Pha\KIND_AWAIT);

  $get_contexts =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CONTEXTS);
  $get_function_modifiers =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_MODIFIERS);

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_DECLARATION_HEADER,
  )
    |> Vec\filter($$, $func ==> {
      if (!Pha\is_missing($get_contexts($func))) {
        return false;
      }

      $modifiers =
        $get_function_modifiers($func) |> Pha\node_get_children($script, $$);

      if (!C\any($modifiers, $is_async)) {
        return false;
      }

      return Pha\node_get_parent($script, $func)
        |> Pha\node_get_descendants($script, $$)
        |> C\any($$, $is_await);
    })
    |> Vec\map(
      $$,
      $func ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $func,
        $linter,
        'This function performs I/O (it contains await), '.
        'so this is likely a good candidate for `[defaults]`.'.
        'If this lint is wrong, add the proper context list.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $get_contexts($func),
            '[defaults]',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      ),
    );
}
