/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function prefer_single_quoted_string_literals_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $token_index,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  // hackfmt-ignore
  $escape_sequences = vec[
    '\\e', // ansi escape
    '\\f', // form feed
    '\\t', // horizontal tab
    '\\r', // carriage return
    '\\n', // newline
    '\\u', // unicode codepoint
    '\\v', // vertical tab
    '\\x', // hex
    "'", // single quote,
    '\$', // anti-variable interpolation
    '\\0', '\\1', '\\2', '\\3', '\\4', '\\5', '\\6', '\\7' // octal
  ];

  return Pha\index_get_nodes_by_kind(
    $token_index,
    Pha\KIND_DOUBLE_QUOTED_STRING_LITERAL,
  )
    |> Vec\map(
      $$,
      $t ==> shape(
        'node' => $t,
        'contents' => Pha\token_get_text($script, $t)
          |> Str\strip_prefix($$, '"')
          |> Str\strip_suffix($$, '"'),
      ),
    )
    |> Vec\filter(
      $$,
      $shape ==>
        !C\any($escape_sequences, $e ==> Str\contains($shape['contents'], $e)),
    )
    |> Vec\map(
      $$,
      $shape ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $shape['node'],
        $linter,
        'This could be a single quoted string.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $shape['node'],
            "'".$shape['contents']."'",
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      ),
    );
}
