/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function solitary_escape_sequences_should_be_disambiguated_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $escape_chars = keyset['e', 'f', 't', 'r', 'n', 'u', 'v', 'x'];

  return Pha\index_get_nodes_by_kind(
    $token_index,
    Pha\KIND_SINGLE_QUOTED_STRING_LITERAL,
  )
    |> Vec\map(
      $$,
      $str ==> shape(
        'node' => $str,
        'contents' => Pha\token_get_text($script, $str)
          |> Str\strip_prefix($$, "'")
          |> Str\strip_suffix($$, "'"),
      ),
    )
    |> Vec\filter($$, $shape ==> {
      $contents = $shape['contents'];
      return Str\length($contents) === 2 &&
        $contents[0] === '\\' &&
        (
          C\contains_key($escape_chars, $contents[1]) ||
          \ctype_digit($contents[1])
        );
    })
    |> Vec\map(
      $$,
      $shape ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $shape['node'],
        $linter,
        'This string literal represents the literal text '.
        $shape['contents'].
        '. The escape sequence is not evaluated. This string could be confused '.
        'for a character literal (which evaluates the escape sequence) by '.
        'developers with experience in another language with C heritage. To '.
        'avoid this confusion, please add a leading backslash to make this '.
        'string visually distinct from character literals from other languages.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $shape['node'],
            "'".Str\replace($shape['contents'], '\\', '\\\\')."'",
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      ),
    );
}
