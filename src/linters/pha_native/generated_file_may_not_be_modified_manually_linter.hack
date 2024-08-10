/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HTL\Pha;

function generated_file_may_not_be_modified_manually_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $digest = Support\extract_digest($script, $pragma_map);

  return $digest is null || $digest['embedded'] === $digest['hashed']
    ? vec[]
    : vec[LintError::create(
      $script,
      $pragma_map,
      Pha\SCRIPT_NODE,
      $linter,
      'This file was generated with a code generator and should not be edited by hand.',
    )];
}
