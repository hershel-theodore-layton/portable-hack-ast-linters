/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function pragma_could_not_be_parsed_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_attribute_specification = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_FILE_ATTRIBUTE_SPECIFICATION,
    Pha\KIND_OLD_ATTRIBUTE_SPECIFICATION,
  );
  $is_call_expression =
    Pha\create_syntax_matcher($script, Pha\KIND_FUNCTION_CALL_EXPRESSION);

  $get_attributes = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_FILE_ATTRIBUTE_SPECIFICATION_ATTRIBUTES,
    Pha\MEMBER_OLD_ATTRIBUTE_SPECIFICATION_ATTRIBUTES,
  )
    |> Pha\returns_syntax($$);
  $get_constructor_call_argument_list = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_CONSTRUCTOR_CALL_ARGUMENT_LIST,
  )
    |> Pha\returns_syntax($$);

  $create_autofix = $pragma ==> {
    if ($is_call_expression($pragma)) {
      $parent = Pha\node_get_parent($script, $pragma);
      return Pha\patch_node(
        $parent,
        '',
        shape('trivia' => Pha\RetainTrivia::NEITHER),
      );
    }

    $noop_patch = Pha\patch_node($pragma, Pha\node_get_code($script, $pragma));

    $has_exactly_one_argument = $get_constructor_call_argument_list($pragma)
      |> Pha\list_get_items_of_children($script, $$)
      |> C\count($$) === 1;

    if (!$has_exactly_one_argument) {
      return $noop_patch;
    }

    $specification = Pha\node_get_syntax_ancestors($script, $pragma)
      |> C\findx($$, $is_attribute_specification);

    $is_exclusively_a_pragma = $get_attributes($specification)
      |> Pha\list_get_items_of_children($script, $$)
      |> C\count($$) === 1;

    return $is_exclusively_a_pragma
      ? Pha\patch_node(
          $specification,
          '',
          shape('trivia' => Pha\RetainTrivia::LEADING),
        )
      : Pha\patch_node(Pha\node_get_parent($script, $pragma), '');
  };

  return $pragma_map->getAllPragmas()
    |> Vec\filter(
      $$,
      $p ==> idx($p[2], 0, '')
        |> Str\trim($$, '"\'')
        |> $$ === 'PhaLinters' || $$ === 'HTL\PhaLinters',
    )
    |> Vec\filter(
      $$,
      $t ==> Vec\drop($t[2], 1)
        |> Vec\map($$, $str ==> Str\trim($str, '"\''))
        |> C\find(
          $$,
          $str ==> !(
            Str\starts_with($str, 'digest:') || Str\starts_with($str, 'fixme:')
          ),
        ) is nonnull,
    )
    |> Vec\map(
      $$,
      $p ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $p[0],
        $linter,
        'Your version of PhaLinters only supports digest:hash and fixme:linter_name',
        Pha\patches($script, $create_autofix($p[0])),
      ),
    );

}
