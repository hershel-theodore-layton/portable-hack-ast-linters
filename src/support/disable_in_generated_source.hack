/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HTL\Pha;
use type HTL\PhaLinters\LintError;

function disable_in_generated_source(
  (function(
    Pha\Script,
    Pha\SyntaxIndex,
    Pha\TokenIndex,
    Pha\Resolver,
    Pha\PragmaMap,
  )[]: vec<LintError>) $linter,
)[]: (function(
  Pha\Script,
  Pha\SyntaxIndex,
  Pha\TokenIndex,
  Pha\Resolver,
  Pha\PragmaMap,
)[]: vec<LintError>) {
  return ($script, $syntax_index, $token_index, $resolver, $pragma_map)[] ==>
    extract_digest($script, $pragma_map) is nonnull
      ? vec[]
      : $linter($script, $syntax_index, $token_index, $resolver, $pragma_map);
}
