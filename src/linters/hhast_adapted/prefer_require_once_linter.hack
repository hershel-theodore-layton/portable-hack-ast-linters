/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function prefer_require_once_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_require_once = Pha\create_token_matcher($script, Pha\KIND_REQUIRE_ONCE);
  $get_require_keyword =
    Pha\create_member_accessor($script, Pha\MEMBER_INCLUSION_REQUIRE);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_INCLUSION_EXPRESSION)
    |> Vec\map($$, $get_require_keyword)
    |> Vec\filter($$, $require_token ==> !$is_require_once($require_token))
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        Pha\node_get_parent($script, $n),
        $linter,
        Str\format(
          'Use require_once instead of %s.',
          Pha\token_get_text($script, Pha\as_token($n)),
        ),
      ),
    );
}
