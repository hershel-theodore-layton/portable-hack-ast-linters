/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

function license_header_linter(
  Pha\Script $script,
  Pha\PragmaMap $pragma_map,
  string $expected_license_header,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_markup_section =
    Pha\create_syntax_matcher($script, Pha\KIND_MARKUP_SECTION);

  $first_thing = Pha\node_get_first_childx($script, Pha\SCRIPT_NODE)
    |> Pha\node_get_children($script, $$)
    |> C\findx($$, $n ==> !$is_markup_section($n));

  $first_token = Support\get_first_token($script, $first_thing)
    |> Pha\as_token($$);
  $token_text = Pha\token_get_text_trivium($script, $first_token);
  // Other comments may precede the license, but code may not.
  $leading_trivia = Pha\node_get_children($script, $first_token)
    |> Support\vec_take_while_inclusive($$, $n ==> $n !== $token_text);

  return $leading_trivia
    |> C\any(
      $$,
      $n ==> Pha\is_trivium($n) &&
        $n !== $token_text &&
        Str\contains(Pha\node_get_code($script, $n), $expected_license_header),
    )
      ? vec[]
      : vec[LintError::createWithPatches(
        $script,
        $pragma_map,
        C\firstx($$),
        $linter,
        'Expected to find your license header at the top of this file: '.
        $expected_license_header,
        Pha\patches($script, Pha\patch_node(
          $first_thing,
          $expected_license_header.
          "\n".
          Pha\node_get_code($script, $first_thing),
        )),
      )];
}
