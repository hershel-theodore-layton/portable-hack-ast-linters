/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Dict, Str};

/** Merge each category; earlier advice wins, ignoring a leading backslash. */
function merge_disallowed_entities(
  TDisallowedEntities ...$configurations
)[]: TDisallowedEntities {
  $functions = dict[];
  $types = dict[];
  $constants = dict[];
  foreach ($configurations as $configuration) {
    $functions = Dict\merge(
      Dict\map_keys(
        Shapes::idx($configuration, 'functions', dict[]),
        $name ==> Str\strip_prefix($name, '\\'),
      ),
      $functions,
    );
    $types = Dict\merge(
      Dict\map_keys(
        Shapes::idx($configuration, 'types', dict[]),
        $name ==> Str\strip_prefix($name, '\\'),
      ),
      $types,
    );
    $constants = Dict\merge(
      Dict\map_keys(
        Shapes::idx($configuration, 'constants', dict[]),
        $name ==> Str\strip_prefix($name, '\\'),
      ),
      $constants,
    );
  }
  return shape(
    'functions' => $functions,
    'types' => $types,
    'constants' => $constants,
  );
}
