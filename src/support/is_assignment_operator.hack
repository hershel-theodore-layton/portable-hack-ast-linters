/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HTL\Pha;

function assignment_operator_matcher(Pha\Script $script)[]: (function(
  Pha\NillableNode,
)[]: bool) {
  return Pha\create_token_matcher(
    $script,
    Pha\KIND_AMPERSAND_EQUAL,
    Pha\KIND_BAR_EQUAL,
    Pha\KIND_CARAT_EQUAL,
    Pha\KIND_DOT_EQUAL,
    Pha\KIND_EQUAL,
    Pha\KIND_GREATER_THAN_GREATER_THAN_EQUAL,
    Pha\KIND_LESS_THAN_LESS_THAN_EQUAL,
    Pha\KIND_MINUS_EQUAL,
    Pha\KIND_PERCENT_EQUAL,
    Pha\KIND_PLUS_EQUAL,
    Pha\KIND_QUESTION_QUESTION_EQUAL,
    Pha\KIND_SLASH_EQUAL,
    Pha\KIND_STAR_EQUAL,
    Pha\KIND_STAR_STAR_EQUAL,
  );
}
