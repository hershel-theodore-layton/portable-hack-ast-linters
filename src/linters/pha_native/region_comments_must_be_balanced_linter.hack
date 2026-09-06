/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Regex;
use namespace HTL\Pha;

function region_comments_must_be_balanced_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_single_line_comment =
    Pha\create_trivium_matcher($script, Pha\KIND_SINGLE_LINE_COMMENT);
  $regions = dict[];
  $depth = 0;

  foreach (Pha\script_get_trivia($script) as $comment) {
    if (!$is_single_line_comment($comment)) {
      continue;
    }

    $marker = Regex\first_match(
      Pha\node_get_code($script, $comment),
      re'@^//\s*\#(?<marker>region|endregion)(?:\s|$)@',
    );
    if ($marker is null) {
      continue;
    }

    if ($marker['marker'] === 'region') {
      $regions[$depth] = $comment;
      ++$depth;
    } else if ($depth !== 0) {
      --$depth;
    } else {
      return vec[
        LintError::createWithoutPatches(
          $script,
          $pragma_map,
          $comment,
          $linter,
          'This `#endregion` comment has no matching `#region`.',
        ),
      ];
    }
  }

  return $depth === 0
    ? vec[]
    : vec[
        LintError::createWithoutPatches(
          $script,
          $pragma_map,
          $regions[0],
          $linter,
          'This `#region` comment has no matching `#endregion`.',
        ),
      ];
}
