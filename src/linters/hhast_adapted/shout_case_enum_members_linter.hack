/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function shout_case_enum_members_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_enumerator =
    Pha\create_member_accessor($script, Pha\MEMBER_ENUMERATOR_NAME)
    |> Pha\returns_token($$);

  return Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_ENUMERATOR)
    |> Vec\filter(
      $$,
      $e ==> $get_enumerator($e)
        |> Pha\token_get_text($script, $$)
        |> Str\uppercase($$) !== $$,
    )
    |> Vec\map(
      $$,
      $e ==> LintError::create(
        $script,
        $pragma_map,
        $e,
        $linter,
        'Rename this enum member to SHOUT_CASE.',
      ),
    );
}
