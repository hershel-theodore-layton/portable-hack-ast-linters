/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\C;
use namespace HTL\Pha;

// This linter implements no_white_space_at_end_of_line_linter.
//
// It also doubles as consistent_line_endings_linter.
// In a unix line ending world, `\r\n` is whitespace at eol, since `\r` is whitespace.
//
// It also triples as must_have_newline_at_end_of_file_linter.
//
// It also quadruples as dont_have_two_empty_lines_in_a_row_linter.
// We are already looking at all the trivia, let's just cram this in here too.
//
// It also also quintuples as no_newline_at_start_of_control_flow_block_linter.
// This linter is similar in style as dont_have_two_empty_lines_in_a_row_linter.
function all_the_whitespace_linters(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $trivia = Pha\script_get_trivia($script);
  $errors = vec[];

  /**
   * @var Is 1 when standing on the last trivium of a control block.
   *
   * ```
   *          V       VVV       VV                   VVVVVVVVVV
   *  if (true) {} or try {} or do {} while(true) or concurrent {}
   * ```
   *  - With 2 we are (when using conventional formatting) at the space.
   *  - With 3 we are at the left brace.
   *  - With 4 or greater, we are heuristically not at the start of a control block.
   */
  $control_block_detector = 0;
  $line_counter = 0;
  $prev_whitespace = false;

  foreach ($trivia as $trivium) {
    $kind = Pha\node_get_kind($script, $trivium);
    $text = Pha\node_get_code($script, $trivium);
    $is_eol = $kind === Pha\KIND_END_OF_LINE;

    // #region dont_have_two_empty_lines_in_a_row_linter +
    // no_newline_at_start_of_control_flow_block_linter
    $control_block_detector *= (int)!(
      $text === ')' ||
      $text === 'try' ||
      $text === 'concurrent' ||
      $text === 'do'
    );
    ++$control_block_detector;

    $invalidate_block_start = $control_block_detector & ~3;
    $block_start = (int)($text === '{') >> $invalidate_block_start;
    $is_eof_trivium = $text === '';

    $is_line = (int)$is_eol | (int)$is_eof_trivium;
    $line_counter = $line_counter * $is_line + ($is_line | $block_start);

    if ($line_counter > 2 && !$is_eof_trivium) {
      $errors[] = new LintError(
        $script,
        $trivium,
        $linter,
        'Too many newlines in a row.',
      );
    }
    // #endregion

    // #region no_whitespace_at_end_of_line_linter | consistent_line_endings_linter
    if ($is_eol && ($prev_whitespace || $text !== "\n")) {
      $errors[] = new LintError(
        $script,
        $trivium,
        $linter,
        'There is whitespace before the end of this line.',
      );
    }

    $prev_whitespace = $kind === Pha\KIND_WHITESPACE;
    // #endregion
  }

  // #region must_have_newline_at_end_of_file_linter
  if ($line_counter === 1) {
    $errors[] = new LintError(
      $script,
      C\lastx($trivia),
      $linter,
      'Files must end with on or more newlines.',
    );
  }
  // #endregion

  return $errors;
}
