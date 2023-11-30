/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace \A\{_Private};
use namespace HH\Lib\{Vec, Str};
use namespace HH\Lib\Dict as NotUsed;
use type HTL\Pragma\Pragmas;
use function HTL\Pragma\pragma;

<<file:
  Pragmas(
    vec['PhaLinters', 'fixme:group_use_statement_alphabetization'],
    vec['PhaLinters', 'fixme:group_use_statements'],
    vec['PhaLinters', 'fixme:license_header'],
    vec['PhaLinters', 'fixme:namespace_private_use_clause'],
    vec['PhaLinters', 'fixme:unused_use_clause'],
    vec['PhaLinters', 'fixme:use_statement_with_as'],
    vec['PhaLinters', 'fixme:use_statement_with_leading_backslash'],
    vec['PhaLinters', 'fixme:whitespace'],
  )>>

<<Pragmas(
  vec['PhaLinters', 'fixme:async_function_and_method'],
  vec['PhaLinters', 'fixme:camel_cased_methods_underscored_functions'],
)>>
async function pragmaExample()[]: Awaitable<void> {
  pragma('PhaLinters', 'fixme:unreachable_code');
  return;

  while (true) {
    pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
    await async {
    };

    pragma('PhaLinters', 'fixme:dont_create_forwarding_lambdas');
    Vec\map(vec[], $x ==> Str\trim($x));

    pragma('PhaLinters', 'fixme:dont_discard_new_expressions');
    new \Exception();

    pragma('PhaLinters', 'fixme:dont_use_asio_join');
    \HH\Asio\join(async {
    });

    pragma('PhaLinters', 'fixme:must_use_braces_for_control_flow');
    if (true) echo 4;

    pragma('PhaLinters', 'fixme:namespace_private_symbol');
    _Private\PRIV;

    pragma('PhaLinters', 'fixme:no_empty_statements');
    4 + 2;

    pragma('PhaLinters', 'fixme:prefer_single_quoted_string_literals');
    $a = "";

    pragma('PhaLinters', 'fixme:no_string_interpolation');
    $_ = "$a";

    pragma('PhaLinters', 'fixme:no_php_equality');
    $_ = 1 != 2;

    pragma('PhaLinters', 'fixme:prefer_lambdas');
    $_ = function() {};

    pragma('PhaLinters', 'fixme:prefer_require_once');
    include __FILE__;

    pragma('PhaLinters', 'fixme:unused_pipe_variable');
    $_ = 0 |> 0;
  }
}

<<Pragmas(vec['PhaLinters', 'fixme:final_or_abstract_classes'])>>
class NotFinal {}

final class IsFinal {
  <<Pragmas(
    vec['PhaLinters', 'fixme:no_final_method_in_final_classes'],
    vec['PhaLinters', 'fixme:unused_variable'],
  )>>
  final public function final(string $x): void {

  }
}

<<Pragmas(vec['PhaLinters', 'fixme:shout_case_enum_members'])>>
enum Naming: int {
  PascalCase = 1;
}