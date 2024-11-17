/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function use_statement_with_leading_backslash_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_backslash = Pha\create_token_matcher($script, Pha\KIND_BACKSLASH);

  $get_leading_backslash = $node ==> Support\get_first_token($script, $node);
  $get_prefix = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_NAME,
    Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX,
  );

  return Vec\concat(
    Pha\index_get_nodes_by_kind(
      $syntax_index,
      Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
    ),
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_USE_CLAUSE),
  )
    |> Vec\map($$, $n ==> $get_prefix($n) |> $get_leading_backslash($$))
    |> Vec\filter($$, $is_backslash)
    |> Vec\map(
      $$,
      $n ==> Pha\as_nonnil($n)
        |> LintError::createWithPatches(
          $script,
          $pragma_map,
          $$,
          $linter,
          'The leading backslashes in use declarations do not have an effect. '.
          'You may remove them.',
          Pha\patches(
            $script,
            Pha\patch_node(
              $$,
              '',
              shape('trivia' => Pha\RetainTrivia::LEADING),
            ),
          ),
        ),
    );
}
