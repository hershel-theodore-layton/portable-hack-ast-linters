/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\Pha;

function async_function_and_method_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_return_type =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_TYPE);

  $is_async = $decl ==> $get_return_type($decl)
    |> Support\get_first_token($script, $$)
    |> Pha\token_get_text($script, Pha\as_token_or_nil($$)) === 'Awaitable';

  return Support\enforce_naming(
    $script,
    $syntax_index,
    ($name, $decl) ==> $is_async($decl) &&
      !Str\ends_with($name, '_async') &&
      !Str\ends_with($name, '_asyncx'),
    ($name, $decl) ==> $is_async($decl) &&
      !Str\starts_with($name, 'test') &&
      !Str\ends_with($name, 'Async') &&
      !Str\ends_with($name, 'Asyncx'),
  )
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'Please use an async suffix (_async, _asyncx, Async, or Asyncx).',
      ),
    );
}
