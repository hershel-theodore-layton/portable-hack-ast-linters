/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

/**
 * Returns a new vec with all elements up until and including the first element
 * for which the predicate holds.
 * If the predicate doesn't hold for any element, all elements are returned.
 *
 * ```
 * $nums = vec[1, 2, 3, 4, 5, 6, 7];
 * vec_take_while_incl_true($nums, $n ==> $n === 4); // vec[1, 2, 3, 4]
 * ```
 */
function vec_take_while_incl_true<T>(
  Traversable<T> $traversable,
  (function(T)[_]: bool) $predicate,
)[ctx $predicate]: vec<T> {
  $out = vec[];

  foreach ($traversable as $el) {
    $out[] = $el;
    if ($predicate($el)) {
      return $out;
    }
  }

  return $out;
}
