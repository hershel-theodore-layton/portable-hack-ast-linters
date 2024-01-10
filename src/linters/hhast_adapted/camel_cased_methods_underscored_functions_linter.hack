/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Regex, Str, Vec};
use namespace HTL\Pha;

function camel_cased_methods_underscored_functions_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
  ?vec<string> $allowed_suffixes = null,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_return_type =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_TYPE);

  $is_factory_func = ($decl, string $name) ==> $get_return_type($decl)
    |> Pha\node_get_code($script, $$)
    |> Str\trim($$)
    |> Str\split($$, '\\')
    |> C\last($$) ?? ''
    |> Str\split($$, '<', 2)
    |> C\first($$) === $name;

  return Support\enforce_naming(
    $script,
    $syntax_index,
    ($name, $decl) ==> !Str\starts_with($name, '__') &&
      !Regex\matches($name, re'/^[a-z0-9_]+$/') &&
      !$is_factory_func($decl, $name),
    ($name, $decl) ==> {
      return !Str\starts_with($name, '__') &&
        !Regex\matches($name, re'/^[a-z][a-zA-Z0-9]*$/') &&
        !$is_factory_func($decl, $name);
    },
    $allowed_suffixes,
  )
    |> Vec\map(
      $$,
      $n ==> LintError::create(
        $script,
        $pragma_map,
        $n,
        $linter,
        'Methods must use camelCase() and functions must use snake_case().',
      ),
    );
}
