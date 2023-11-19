/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace \A\{_Private};
use namespace HH\Lib\{Vec, Str};
use namespace HH\Lib\Dict as NotUsed;
use type HTL\Pragma\Pragmas;
use function HTL\Pragma\pragma;

<<file:
  Pragmas(
    vec['PhaLinters', 'ignore:group_use_statement_alphabetization'],
    vec['PhaLinters', 'ignore:group_use_statements'],
    vec['PhaLinters', 'ignore:license_header'],
    vec['PhaLinters', 'ignore:namespace_private_use_clause'],
    vec['PhaLinters', 'ignore:unused_use_clause'],
    vec['PhaLinters', 'ignore:use_statement_with_as'],
    vec['PhaLinters', 'ignore:use_statement_with_leading_backslash'],
    vec['PhaLinters', 'ignore:whitespace'],
  )>>

<<Pragmas(
  vec['PhaLinters', 'ignore:async_function_and_method'],
  vec['PhaLinters', 'ignore:camel_cased_methods_underscored_functions'],
)>>
async function pragmaExample()[]: Awaitable<void> {
  pragma('PhaLinters', 'ignore:unreachable_code');
  return;

  while (true) {
    pragma('PhaLinters', 'ignore:dont_await_in_a_loop');
    await async {
    };

    pragma('PhaLinters', 'ignore:dont_create_forwarding_lambdas');
    Vec\map(vec[], $x ==> Str\trim($x));

    pragma('PhaLinters', 'ignore:dont_discard_new_expressions');
    new \Exception();

    pragma('PhaLinters', 'ignore:dont_use_asio_join');
    \HH\Asio\join(async {
    });

    pragma('PhaLinters', 'ignore:must_use_braces_for_control_flow');
    if (true) echo 4;

    pragma('PhaLinters', 'ignore:namespace_private_symbol');
    _Private\PRIV;

    pragma('PhaLinters', 'ignore:no_empty_statements');
    4 + 2;

    pragma('PhaLinters', 'ignore:prefer_single_quoted_string_literals');
    $a = "";

    pragma('PhaLinters', 'ignore:no_string_interpolation');
    $_ = "$a";

    pragma('PhaLinters', 'ignore:no_php_equality');
    $_ = 1 != 2;

    pragma('PhaLinters', 'ignore:prefer_lambdas');
    $_ = function() {};

    pragma('PhaLinters', 'ignore:prefer_require_once');
    include '';

    pragma('PhaLinters', 'ignore:unused_pipe_variable');
    $_ = 0 |> 0;
  }
}

<<Pragmas(vec['PhaLinters', 'ignore:final_or_abstract_classes'])>>
class NotFinal {}

final class IsFinal {
  <<Pragmas(
    vec['PhaLinters', 'ignore:no_final_method_in_final_classes'],
    vec['PhaLinters', 'ignore:unused_variable'],
  )>>
  final public function final(string $x): void {

  }
}

<<Pragmas(vec['PhaLinters', 'ignore:shout_case_enum_members'])>>
enum Naming: int {
  PascalCase = 1;
}