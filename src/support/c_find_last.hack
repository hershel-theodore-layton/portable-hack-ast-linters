/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\C;

function c_find_last<T>(
  vec<T> $values,
  (function(T)[_]: bool) $predicate,
)[ctx $predicate]: ?T {
  for ($i = C\count($values) - 1; $i >= 0; --$i) {
    $value = $values[$i];
    if ($predicate($value)) {
      return $value;
    }
  }

  return null;
}
