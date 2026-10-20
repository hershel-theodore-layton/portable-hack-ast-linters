/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\{C, Str};
use namespace HTL\{Pha, PhaLinters, TestChain};

<<TestChain\Discover>>
function decorator_tests(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('decorator_test', decorator_test<>)
    ->test('Digest excludes its pragma payload', digest_test<>);
}

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
    $resolver =
      Pha\create_name_resolver_v2($script, $syntax_index, $token_index);
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

function digest_test()[]: void {
  foreach (
    vec[
      "use type HTL\\Pragma\\Pragmas;\n".
      "<<file: Pragmas(vec['PhaLinters', 'digest:'])>>\n",
      "use type HTL\\Pragma\\Pragmas;\n".
      '<<file: Pragmas(vec["HTL\\PhaLinters", /* digest: before */ "digest:" /* digest: after */])>>'.
      "\n",
      "use type HTL\\Pragma\\Pragmas;\n".
      "<<file: Pragmas(vec['Other', 'digest:'], vec['PhaLinters', 'digest:'])>>\n",
      "use function HTL\\Pragma\\pragma;\n".
      "pragma('PhaLinters', /* digest: before */ 'digest:' /* digest: after */);\n",
    ] as $header
  ) {
    $source = $header."function value(): string { return 'text'; }\n";
    list($script, $_) = Pha\parse($source, Pha\create_context());
    $pragma_map =
      Pha\create_pragma_map($script, Pha\create_syntax_kind_index($script));
    $signed = PhaLinters\Support\insert_digest($script, $pragma_map);
    $digest = PhaLinters\Support\extract_digest($script, $pragma_map)
      as nonnull;
    foreach (
      vec[
        tuple($signed, 0),
        tuple(Str\replace($signed, "'text'", "'changed'"), 1),
        tuple(Str\replace($signed, "'text'", "'text".$digest['hashed']."'"), 1),
        tuple($signed.'// '.$digest['hashed']."\n", 1),
      ] as list($code, $expected)
    ) {
      list($script, $_) = Pha\parse($code, Pha\create_context());
      $syntax_index = Pha\create_syntax_kind_index($script);
      $token_index = Pha\create_token_kind_index($script);
      $pragma_map = Pha\create_pragma_map($script, $syntax_index);
      $errors = PhaLinters\generated_file_may_not_be_modified_manually_linter(
        $script,
        $syntax_index,
        $token_index,
        Pha\create_name_resolver_v2($script, $syntax_index, $token_index),
        $pragma_map,
      );
      invariant(
        C\count($errors) === $expected,
        'Expected %d digest diagnostics for %s',
        $expected,
        $code,
      );
    }
  }
}
