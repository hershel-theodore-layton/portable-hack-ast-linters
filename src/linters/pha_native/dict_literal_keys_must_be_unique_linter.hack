/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Dict, Str, Vec};
use namespace HTL\Pha;

function dict_literal_keys_must_be_unique_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_dict_key = Pha\create_member_accessor($script, Pha\MEMBER_ELEMENT_KEY);
  $get_dict_members =
    Pha\create_member_accessor($script, Pha\MEMBER_DICTIONARY_INTRINSIC_MEMBERS)
    |> Pha\returns_syntax($$);
  $is_element_initializer =
    Pha\create_syntax_matcher($script, Pha\KIND_ELEMENT_INITIALIZER);

  return Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_DICTIONARY_INTRINSIC_EXPRESSION,
  )
    |> Vec\map(
      $$,
      $dict ==>
        Pha\list_get_items_of_children($script, $get_dict_members($dict))
        |> Vec\filter($$, $is_element_initializer)
        |> Vec\map(
          $$,
          $member ==> Pha\as_syntax($member)
            |> $get_dict_key($$)
            |> tuple(Pha\node_get_code_compressed($script, $$), $$),
        )
        |> Dict\group_by($$, $key ==> $key[0])
        |> Vec\map($$, $keys ==> Vec\drop($keys, 1)),
    )
    |> Vec\flatten($$)
    |> Vec\flatten($$)
    |> Vec\map(
      $$,
      $key ==> LintError::create(
        $script,
        $pragma_map,
        $key[1],
        $linter,
        Str\format(
          'This key is already part of this dict and will therefore overwrite '.
          'the previous one.  `%s`',
          $key[0],
        ),
      ),
    );
}
