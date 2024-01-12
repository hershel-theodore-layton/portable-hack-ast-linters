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
function whitespace_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $_,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $trivia = Pha\script_get_trivia($script);
  $errors = vec[];

  $line_counter = 0;
  $prev_whitespace = false;

  foreach ($trivia as $trivium) {
    $kind = Pha\node_get_kind($script, $trivium);
    $text = Pha\node_get_code($script, $trivium);
    $is_eol = $kind === Pha\KIND_END_OF_LINE;

    // #region dont_have_two_empty_lines_in_a_row_linter
    $is_eof_trivium = $text === '';

    $is_line = (int)$is_eol | (int)$is_eof_trivium;
    $line_counter = $line_counter * $is_line + $is_line;

    if ($line_counter > 2 && !$is_eof_trivium) {
      $errors[] = LintError::create(
        $script,
        $pragma_map,
        $trivium,
        $linter,
        'Too many newlines in a row.',
      );
    }
    // #endregion

    // #region no_whitespace_at_end_of_line_linter | consistent_line_endings_linter
    if ($is_eol && ($prev_whitespace || $text !== "\n")) {
      $errors[] = LintError::create(
        $script,
        $pragma_map,
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
    $errors[] = LintError::create(
      $script,
      $pragma_map,
      C\lastx($trivia),
      $linter,
      'Files must end with on or more newlines.',
    );
  }
  // #endregion

  return $errors;
}
