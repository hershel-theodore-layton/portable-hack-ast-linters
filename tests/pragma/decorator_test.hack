/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\C;
use namespace HTL\{Pha, PhaLinters};

function decorator_test()[]: void {
  $linter = PhaLinters\Support\disable_in_generated_source(
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
  );
  $ctx = Pha\create_context();

  foreach (
    vec[
      tuple("namespace Example;\nfunction camelCasedFunction(): void {}\n", 1),
      tuple(
        "namespace Example;\n".
        "use type HTL\\Pragma\\Pragmas;\n".
        "<<file: Pragmas(vec['PhaLinters', 'digest:'])>>\n".
        "function camelCasedFunction(): void {}\n",
        0,
      ),
    ] as list($source, $expected_error_count)
  ) {
    list($script, $ctx) = Pha\parse($source, $ctx);
    $syntax_index = Pha\create_syntax_kind_index($script);
    $token_index = Pha\create_token_kind_index($script);
    $resolver = Pha\create_name_resolver($script, $syntax_index, $token_index);
    $pragma_map = Pha\create_pragma_map($script, $syntax_index);

    $errors =
      $linter($script, $syntax_index, $token_index, $resolver, $pragma_map);
    if (C\count($errors) !== $expected_error_count) {
      throw new \Exception(
        'disable_in_generated_source returned an unexpected error count',
      );
    }
  }
}
