/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{Dict, Vec};
use namespace HTL\Pha;

function get_flattened_namespace_uses(
  Pha\Script $script,
  vec<Pha\Syntax> $use_declarations,
  vec<Pha\Syntax> $group_use_declarations,
)[]: dict<UseKind, vec<(Pha\Syntax, string)>> {
  $is_const = Pha\create_token_matcher($script, Pha\KIND_CONST);
  $is_function = Pha\create_token_matcher($script, Pha\KIND_FUNCTION);
  $is_name = Pha\create_token_matcher($script, Pha\KIND_NAME);
  $is_namespace = Pha\create_token_matcher($script, Pha\KIND_NAMESPACE);
  $is_type = Pha\create_token_matcher($script, Pha\KIND_TYPE);

  $get_kind = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  );

  $get_grouped_prefix =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX);
  $get_qualified_name_parts =
    Pha\create_member_accessor($script, Pha\MEMBER_QUALIFIED_NAME_PARTS);
  $get_clauses = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_CLAUSES,
    Pha\MEMBER_NAMESPACE_GROUP_USE_CLAUSES,
  );
  $get_clause_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);

  $parse_clause = $clause ==> {
    $name = $get_clause_name($clause);
    if ($is_name($name)) {
      return Pha\as_token($name) |> Pha\token_get_text($script, $$);
    }

    return Pha\as_syntax($name)
      |> qualified_name_to_string($script, $$, $get_qualified_name_parts);
  };

  $parse_group_prefix = $use ==> $get_grouped_prefix($use)
    |> qualified_name_to_string(
      $script,
      Pha\as_syntax($$),
      $get_qualified_name_parts,
    );

  $get_kind_as_enum = $use ==> $get_kind($use)
    |> $is_const($$)
      ? UseKind::CONST
      : (
          $is_function($$)
            ? UseKind::FUNCTION
            : (
                $is_namespace($$)
                  ? UseKind::NAMESPACE
                  : ($is_type($$) ? UseKind::TYPE : UseKind::NONE)
              )
        );

  $use_clauses = Dict\group_by($use_declarations, $get_kind_as_enum)
    |> Dict\map(
      $$,
      $uses ==> Vec\map(
        $uses,
        $u ==> Pha\as_syntax($u)
          |> $get_clauses($$)
          |> Pha\as_syntax($$)
          |> Pha\list_get_items_of_children($script, $$),
      )
        |> Vec\flatten($$)
        |> Vec\map(
          $$,
          $c ==> Pha\as_syntax($c) |> tuple($$, $parse_clause($$)),
        ),
    );

  $grouped_uses = Dict\group_by($group_use_declarations, $get_kind_as_enum)
    |> Dict\map(
      $$,
      $v ==> Vec\map($v, $u ==> {
        $prefix = $parse_group_prefix($u);
        return $get_clauses($u)
          |> Pha\as_syntax($$)
          |> Pha\list_get_items_of_children($script, $$)
          |> Vec\map(
            $$,
            $c ==>
              Pha\as_syntax($c) |> tuple($$, $prefix.'\\'.$parse_clause($$)),
          );
      })
        |> Vec\flatten($$),
    );

  return dict_merge_by_concatting_values($use_clauses, $grouped_uses);
}
