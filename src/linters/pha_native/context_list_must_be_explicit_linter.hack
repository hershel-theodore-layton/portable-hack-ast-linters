/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function context_list_must_be_explicit_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_contexts = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_FUNCTION_CONTEXTS,
    Pha\MEMBER_CLOSURE_CONTEXTS,
  );

  return Vec\concat(
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_FUNCTION_DECLARATION_HEADER,
    ),
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_CLOSURE_TYPE_SPECIFIER, //
    ),
  )
    |> Vec\filter($$, $func ==> Pha\is_missing($get_contexts($func)))
    |> Vec\map(
      $$,
      $func ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $func,
        $linter,
        'This function implicitly uses `[defaults]`. '.
        'If this is intentional, please specify as such. '.
        'If not, please provide a more restrictive context list.',
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
