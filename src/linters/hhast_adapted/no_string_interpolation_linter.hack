/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_string_interpolation_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  return Vec\concat(
    Pha\index_get_nodes_by_kind(
      $token_index,
      Pha\KIND_DOUBLE_QUOTED_STRING_LITERAL_HEAD,
    ),
    Pha\index_get_nodes_by_kind(
      $token_index,
      Pha\KIND_HEREDOC_STRING_LITERAL_HEAD,
    ),
  )
    |> Vec\map(
      $$,
      $h ==> new LintError(
        $script,
        Pha\node_get_parent($script, $h),
        $linter,
        'Avoid string interpolation, consider concatenation or Str\\format(...).',
      ),
    );
}
