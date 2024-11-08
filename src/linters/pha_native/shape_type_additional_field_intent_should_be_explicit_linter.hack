/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function shape_type_additional_field_intent_should_be_explicit_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\PragmaMap $pragma_map,
  string $closed_shape_marker,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_shape_fields =
    Pha\create_member_accessor($script, Pha\MEMBER_SHAPE_TYPE_FIELDS)
    |> Pha\returns_syntax($$);
  $get_shape_left_paren =
    Pha\create_member_accessor($script, Pha\MEMBER_SHAPE_TYPE_LEFT_PAREN);
  $get_shape_right_paren =
    Pha\create_member_accessor($script, Pha\MEMBER_SHAPE_TYPE_RIGHT_PAREN);
  $get_shape_ellipsis =
    Pha\create_member_accessor($script, Pha\MEMBER_SHAPE_TYPE_ELLIPSIS);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_SHAPE_TYPE_SPECIFIER)
    |> Vec\filter($$, $shape ==> {
      if (!Pha\is_missing($get_shape_ellipsis($shape))) {
        return false;
      }

      $right_paren = $get_shape_right_paren($shape);

      $token_before_right_paren = $get_shape_fields($shape)
        |> Pha\node_get_children($script, $$)
        |> C\last($$)
        |> $$ is nonnull
          ? Support\get_last_token($script, $$)
          : $get_shape_left_paren($shape);

      return !C\any(
        vec[$token_before_right_paren, $right_paren],
        $x ==> Pha\node_get_code($script, $x)
          |> Str\contains($$, $closed_shape_marker),
      );
    })
    |> Vec\map(
      $$,
      $shape ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $shape,
        $linter,
        'The intent of whether this shape accepts additional fields is not expliticly expressed. '.
        'If you intended to accept these fields, and any number of unspecified fields, '.
        'add `, ...` after the last field. If you can not want to accept additional fields, add '.
        $closed_shape_marker.
        ' before the closing parenthesis.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $get_shape_right_paren($shape),
            $closed_shape_marker.
            "\n".
            Pha\node_get_code($script, $get_shape_right_paren($shape)),
            shape('trivia' => Pha\RetainTrivia::NEITHER),
          ),
        ),
      ),
    );
}
