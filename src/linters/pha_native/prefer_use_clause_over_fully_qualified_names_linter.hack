/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

function prefer_use_clause_over_fully_qualified_names_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $is_declaration = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_NAMESPACE_DECLARATION_HEADER,
    Pha\KIND_NAMESPACE_USE_DECLARATION,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  );
  $is_function = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_FUNCTION_CALL_EXPRESSION,
    Pha\KIND_FUNCTION_POINTER_EXPRESSION,
  );
  $is_type = Pha\create_syntax_matcher(
    $script,
    Pha\KIND_CONSTRUCTOR_CALL,
    Pha\KIND_GENERIC_TYPE_SPECIFIER,
    Pha\KIND_SCOPE_RESOLUTION_EXPRESSION,
    Pha\KIND_SIMPLE_TYPE_SPECIFIER,
    Pha\KIND_TYPE_PARAMETER,
  );

  $errors = vec[];
  foreach (
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_QUALIFIED_NAME) as
      $node
  ) {
    $name = Pha\node_get_code_compressed($script, $node);
    if (!Str\starts_with($name, '\\')) {
      continue;
    }

    $ancestors = Pha\node_get_syntax_ancestors($script, $node);
    if (C\any($ancestors, $is_declaration)) {
      continue;
    }

    $name = Str\strip_prefix($name, '\\');
    $separator = Str\search_last($name, '\\');
    if ($separator is nonnull) {
      $kind = 'namespace';
      $import = Str\slice($name, 0, $separator);
    } else {
      $parent = C\firstx($ancestors);
      $kind = $is_function($parent)
        ? 'function'
        : ($is_type($parent) ? 'type' : 'const');
      $import = $name;
    }

    $errors[] = LintError::createWithoutPatches(
      $script,
      $pragma_map,
      $node,
      __FUNCTION__,
      Str\format(
        'Add a use clause for this; Consider `use %s %s;`.',
        $kind,
        $import,
      ),
    );
  }

  return $errors;
}
