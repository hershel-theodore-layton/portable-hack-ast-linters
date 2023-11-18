/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{C, Vec};

function dict_merge_by_concatting_values<Tk as arraykey, Tv>(
  KeyedTraversable<Tk, vec<Tv>> $first,
  KeyedTraversable<Tk, Container<Tv>> ...$rest
)[]: dict<Tk, vec<Tv>> {
  $out = dict($first);

  foreach ($rest as $r) {
    foreach ($r as $k => $vs) {
      if (C\contains_key($out, $k)) {
        $out[$k] = Vec\concat($out[$k], $vs);
      } else {
        $out[$k] = vec($vs);
      }
    }
  }

  return $out;
}
