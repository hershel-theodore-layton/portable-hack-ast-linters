/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\Vec;
use namespace HTL\Pha;

function no_php_equality_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $index,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $is_php_equals = Pha\create_token_matcher(
    $script,
    Pha\KIND_EQUAL_EQUAL,
    Pha\KIND_EXCLAMATION_EQUAL,
  );

  $get_operator = Pha\create_member_accessor($script, dict[
    Pha\KIND_BINARY_EXPRESSION => Pha\MEMBER_BINARY_OPERATOR,
  ]);

  $binop_is_php_equals = ($binop) ==>
    $get_operator($binop) |> $is_php_equals($$);

  return
    Pha\script_get_nodes_by_kind($script, $index, Pha\KIND_BINARY_EXPRESSION)
    |> Vec\filter($$, $binop_is_php_equals)
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'Do not use `==` or `!=`. '.
        'The behaviors of these operators are difficult to explain.',
      ),
    );
}
