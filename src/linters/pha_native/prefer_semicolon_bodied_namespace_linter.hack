/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Vec};
use namespace HTL\Pha;

function prefer_semicolon_bodied_namespace_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_eof = Pha\create_token_matcher($script, Pha\KIND_END_OF_FILE_TOKEN);
  $tokens = Pha\script_get_tokens($script);
  $first_token = C\first($tokens);
  $last_token = Support\c_find_last($tokens, $token ==> !$is_eof($token));

  $get_header = Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_HEADER)
    |> Pha\returns_syntax($$);
  $get_keyword =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_KEYWORD);
  $get_name = Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_NAME);
  $get_left_brace =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_LEFT_BRACE);
  $get_right_brace =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_RIGHT_BRACE);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_BODY)
    |> Vec\map($$, $body ==> {
      $namespace = Pha\syntax_get_parent($script, $body);
      $header = $get_header($namespace);
      $keyword = $get_keyword($header);
      $right_brace = $get_right_brace($body);
      $is_global = Pha\is_missing($get_name($header));
      $patches = null;

      if ($first_token === $keyword && $last_token === $right_brace) {
        $edits = vec[
          Pha\patch_node(
            $get_left_brace($body),
            $is_global ? '' : ';',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
          Pha\patch_node(
            $right_brace,
            '',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ];
        if ($is_global) {
          $edits[] = Pha\patch_node(
            $keyword,
            '',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          );
        }
        $patches = Pha\patches($script, ...$edits);
      }

      return LintError::createWithPatches(
        $script,
        $pragma_map,
        $namespace,
        $linter,
        $is_global
          ? 'namespace {} does not create an anonymous namespace, it is a noop.'
          : 'Prefer `namespace Foo;` over `namespace Foo {}`.',
        $patches,
      );
    });
}
