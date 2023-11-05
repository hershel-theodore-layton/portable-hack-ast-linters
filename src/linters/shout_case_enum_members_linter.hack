/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function shout_case_enum_members_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_enumerator = Pha\create_member_accessor($script, dict[
    Pha\KIND_ENUMERATOR => Pha\MEMBER_ENUMERATOR_NAME,
  ]);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_ENUMERATOR)
    |> Vec\filter(
      $$,
      $e ==> $get_enumerator($e)
        |> Pha\as_token($$)
        |> Pha\token_get_text($script, $$)
        |> Str\uppercase($$) !== $$,
    )
    |> Vec\map(
      $$,
      $e ==> new LintError(
        $script,
        $e,
        $linter,
        'Rename this enum member to SHOUT_CASE.',
      ),
    );
}
