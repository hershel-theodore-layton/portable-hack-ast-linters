/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function use_statement_order_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;
  $is_use = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_NAMESPACE_USE_DECLARATION,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  );
  $is_group_use = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  );
  $get_declarations = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_SCRIPT_DECLARATIONS,
    Pha\MEMBER_NAMESPACE_DECLARATIONS,
  );
  $get_kind = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  );
  $get_prefix =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX);
  $get_clauses =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_CLAUSES)
    |> Pha\returns_syntax($$);
  $get_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);
  $kind_order =
    dict['namespace' => 0, 'type' => 1, 'function' => 2, 'const' => 3];

  $bodies = Vec\concat(
    vec[Pha\SCRIPT_NODE],
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_BODY),
  );

  $errors = vec[];
  foreach ($bodies as $body) {
    $previous = null;
    $reported = false;
    foreach (
      Pha\node_get_children($script, $get_declarations($body)) as $node
    ) {
      if (!$is_use($node)) {
        $previous = null;
        $reported = false;
        continue;
      }

      $use = Pha\as_syntax($node);
      $kind = $get_kind($use)
        |> Pha\node_get_code_compressed($script, $$)
        |> Str\lowercase($$)
        |> idx($kind_order, $$);
      // PHP-ish `use Foo` without a kind do not have a specified order.
      if ($kind is null) {
        $previous = null;
        $reported = false;
        continue;
      }

      if ($is_group_use($use)) {
        $prefix_node = $get_prefix($use);
      } else {
        // For cases like `use const X, Y, Z`, we treat this as `use const X;`
        $clause = Pha\list_get_items_of_children($script, $get_clauses($use))
          |> C\first($$);
        if ($clause is null) {
          $previous = null;
          $reported = false;
          continue;
        }
        $prefix_node = $get_name(Pha\as_syntax($clause));
      }
      $prefix = Pha\node_get_code_compressed($script, $prefix_node)
        |> Str\strip_prefix($$, '\\');
      $key = (string)$kind.';'.$prefix;
      if (
        $previous is nonnull && !$reported && Str\compare($previous, $key) > 0
      ) {
        $errors[] = LintError::createWithoutPatches(
          $script,
          $pragma_map,
          $use,
          $linter,
          'Consecutive use statements should be ordered by kind '.
          '(namespace, type, function, const), then alphabetically.',
        );
        $reported = true;
      }
      $previous = $key;
    }
  }
  return $errors;
}
