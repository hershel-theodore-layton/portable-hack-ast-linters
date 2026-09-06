/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function use_statement_could_be_removed_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_namespace_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_NAMESPACE_DECLARATION);
  $is_empty_body =
    Pha\create_syntax_matcher($script, Pha\KIND_NAMESPACE_EMPTY_BODY);
  $is_group = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  );
  $is_namespace = Pha\create_token_matcher($script, Pha\KIND_NAMESPACE);
  $is_function = Pha\create_token_matcher($script, Pha\KIND_FUNCTION);
  $is_type = Pha\create_token_matcher($script, Pha\KIND_TYPE);
  $get_header = Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_HEADER)
    |> Pha\returns_syntax($$);
  $get_namespace_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_NAME);
  $get_body = Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_BODY);
  $get_clauses = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_CLAUSES,
    Pha\MEMBER_NAMESPACE_GROUP_USE_CLAUSES,
  )
    |> Pha\returns_syntax($$);
  $get_kind = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  );
  $get_prefix =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX);
  $get_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);

  $semicolon_namespaces =
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_DECLARATION)
    |> Vec\filter($$, $n ==> $is_empty_body($get_body($n)))
    |> Vec\reverse($$);

  $errors = vec[];
  foreach (
    Vec\concat(
      Pha\index_get_nodes_by_kind(
        $syntax_index,
        Pha\KIND_NAMESPACE_USE_DECLARATION,
      ),
      Pha\index_get_nodes_by_kind(
        $syntax_index,
        Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
      ),
    ) as $use
  ) {
    $namespace = Pha\node_get_syntax_ancestors($script, $use)
      |> C\find($$, $is_namespace_declaration);
    $namespace ??= C\find(
      $semicolon_namespaces,
      $n ==> Pha\node_get_source_order($n) < Pha\node_get_source_order($use),
    );
    if ($namespace is null) {
      continue;
    }

    $current_namespace = $get_namespace_name($get_header($namespace))
      |> Pha\node_get_code_compressed($script, $$)
      |> Str\trim($$, '\\');
    if ($current_namespace === '') {
      continue;
    }

    $kind = $get_kind($use);
    if (Pha\is_missing($kind)) {
      continue;
    }

    $prefix = $is_group($use)
      ? Pha\node_get_code_compressed($script, $get_prefix($use))
      : '';
    foreach (
      Pha\list_get_items_of_children($script, $get_clauses($use)) as $node
    ) {
      $clause = Pha\as_syntax($node);
      $name = $prefix.Pha\node_get_code_compressed($script, $get_name($clause))
        |> Str\strip_prefix($$, '\\');
      $is_current_namespace =
        $is_namespace($kind) && $name === $current_namespace;
      $short_name = Str\split($name, '\\') |> C\lastx($$);
      $is_direct_member = $name === $current_namespace.'\\'.$short_name;
      if (!$is_current_namespace && !$is_direct_member) {
        continue;
      }

      // `use type X\Vector` is useful in namespace `X` because of the auto import.
      if (
        (
          $is_function($kind) &&
          C\contains(Pha\_Private\AUTO_IMPORTED_FUNCTIONS, $short_name)
        ) ||
        (
          $is_type($kind) &&
          C\contains(Pha\_Private\AUTO_IMPORTED_TYPES, $short_name)
        )
      ) {
        continue;
      }

      $errors[] = LintError::createWithoutPatches(
        $script,
        $pragma_map,
        $clause,
        $linter,
        $is_current_namespace
          ? 'This imports the current namespace. This is redundant. If you must '.
            'disambiguate an ambiguous symbol, use `namespace\Symbol` there.'
          : Str\format(
              'This use clause creates a name you already had. '.
              'You can refer to it as `%s` without this use clause.',
              $short_name,
            ),
      );
    }
  }

  return $errors;
}
