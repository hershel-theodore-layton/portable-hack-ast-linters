/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

function license_header_linter(
  Pha\Script $script,
  string $expected_license_header,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_markup_section =
    Pha\create_syntax_matcher($script, Pha\KIND_MARKUP_SECTION);

  return Pha\node_get_first_childx($script, Pha\SCRIPT_NODE)
    |> Pha\node_get_children($script, $$)
    |> C\findx($$, $n ==> !$is_markup_section($n))
    |> Pha\node_get_descendants($script, $$)
    |> C\any(
      $$,
      $n ==> Pha\is_trivium($n) &&
        Str\contains(Pha\node_get_code($script, $n), $expected_license_header),
    )
      ? vec[]
      : vec[new LintError(
        $script,
        C\firstx($$),
        $linter,
        'Expected the find your license header at the top of this file: '.
        $expected_license_header,
      )];
}
