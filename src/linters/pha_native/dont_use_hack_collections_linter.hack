/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function dont_use_hack_collections_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $resolver,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  // hackfmt-ignore
  $collection_types = keyset[
    'Vector', 'ImmVector', 'HH\\Vector', 'HH\\ImmVector',
    'ConstVector', 'MutableVector', 'VectorIterator',
    'ConstIndexAccess', 'IndexAccess',

    'Map', 'ImmMap', 'HH\\Map', 'HH\\ImmMap',
    'ConstMap', 'MutableMap', 'MapIterator',
    'ConstMapAccess', 'MapAccess',

    'Set', 'ImmSet', 'HH\\Set', 'HH\\ImmSet',
    'ConstSet', 'MutableSet', 'SetIterator',
    'ConstSetAccess', 'SetAccess',

    'Pair', 'HH\\Pair', 'PairIterator',
    'Collection', 'HH\\Collection',
    'ConstCollection', 'OutputCollection',
  ];

  $get_reference = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_SIMPLE_TYPE_SPECIFIER,
    Pha\MEMBER_GENERIC_CLASS_TYPE,
    Pha\MEMBER_CONSTRUCTOR_CALL_TYPE,
    Pha\MEMBER_SCOPE_RESOLUTION_QUALIFIER,
    Pha\MEMBER_COLLECTION_LITERAL_NAME,
  );
  $is_name = Pha\create_matcher(
    $script,
    vec[Pha\KIND_QUALIFIED_NAME],
    vec[Pha\KIND_NAME],
    vec[],
  );

  $references = vec[
    Pha\KIND_SIMPLE_TYPE_SPECIFIER,
    Pha\KIND_GENERIC_TYPE_SPECIFIER,
    Pha\KIND_CONSTRUCTOR_CALL,
    Pha\KIND_SCOPE_RESOLUTION_EXPRESSION,
    Pha\KIND_COLLECTION_LITERAL_EXPRESSION,
  ]
    |> Vec\map($$, $k ==> Pha\index_get_nodes_by_kind($syntax_index, $k))
    |> Vec\flatten($$)
    |> Vec\sort_by($$, Pha\node_get_source_order<>);

  $errors = vec[];
  foreach ($references as $reference) {
    $name = $get_reference($reference);
    if (!$is_name($name)) {
      continue;
    }

    $resolved = Pha\resolve_name($resolver, $script, $name);

    if (!C\contains($collection_types, $resolved)) {
      continue;
    }

    $errors[] = LintError::createWithoutPatches(
      $script,
      $pragma_map,
      $name,
      $linter,
      Str\format(
        "Don't use the Hack collection %s. Use Hack arrays instead.",
        $resolved,
      ),
    );
  }

  return $errors;
}
