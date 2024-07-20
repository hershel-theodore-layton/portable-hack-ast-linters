/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\{C, Dict, File, Str, Vec};
use namespace HTL\{Pha, PhaLinters};
use function HH\fun_get_function;

<<__EntryPoint>>
async function pragma_test_async(): Awaitable<void> {
  // Ignoring no_elseif and use_statement_without_kind.
  // They make the file unparsable for other linters.
  // This list of linters, although long, isn't exhaustive.
  // I believe the tests for the pragma system to be so thorough that
  // extending this list wouldn't find problems anymore; leaving it as-is.
  $linters = vec[
    PhaLinters\async_function_and_method_linter<>,
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
    PhaLinters\dont_await_in_a_loop_linter<>,
    PhaLinters\dont_create_forwarding_lambdas_linter<>,
    PhaLinters\dont_discard_new_expressions_linter<>,
    PhaLinters\dont_use_asio_join_linter<>,
    PhaLinters\final_or_abstract_classes_linter<>,
    PhaLinters\group_use_statement_alphabetization_linter<>,
    PhaLinters\group_use_statements_linter<>,
    PhaLinters\must_use_braces_for_control_flow_linter<>,
    PhaLinters\namespace_private_symbol_linter<>,
    PhaLinters\namespace_private_use_clause_linter<>,
    PhaLinters\no_empty_statements_linter<>,
    PhaLinters\no_final_method_in_final_classes_linter<>,
    PhaLinters\no_string_interpolation_linter<>,
    PhaLinters\no_php_equality_linter<>,
    PhaLinters\prefer_lambdas_linter<>,
    PhaLinters\prefer_single_quoted_string_literals_linter<>,
    PhaLinters\prefer_require_once_linter<>,
    PhaLinters\shout_case_enum_members_linter<>,
    PhaLinters\unreachable_code_linter<>,
    PhaLinters\unused_pipe_variable_linter<>,
    PhaLinters\unused_use_clause_linter<>,
    PhaLinters\unused_variable_linter<>,
    PhaLinters\use_statement_with_as_linter<>,
    PhaLinters\use_statement_with_leading_backslash_linter<>,
    PhaLinters\whitespace_linter<>,
  ]
    |> Dict\from_values($$, fun_get_function<>)
    |> Dict\map_keys(
      $$,
      $f ==> Str\slice($f, Str\search_last($f, '\\') as nonnull + 1),
    );

  $linters['license_header_linter'] = ($script, $_, $_, $_, $pragma_map)[] ==>
    PhaLinters\license_header_linter(
      $script,
      $pragma_map,
      '/* Example License Text */',
    );

  $file = File\open_read_only(__DIR__.'/pragma_example.hack');
  using ($file->closeWhenDisposed(), $file->tryLockx(File\LockType::SHARED)) {
    $pragma_example = await $file->readAllAsync();
  }

  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($pragma_example, $ctx);
  $syntax_index = Pha\create_syntax_kind_index($script);
  $token_index = Pha\create_token_kind_index($script);
  $resolver = Pha\create_name_resolver($script, $syntax_index, $token_index);
  $pragma_map = Pha\create_pragma_map($script, $syntax_index);

  foreach ($linters as $linter_name => $linter) {
    $errors =
      $linter($script, $syntax_index, $token_index, $resolver, $pragma_map);
    if (C\is_empty($errors)) {
      throw new \Exception('Expected an error for: '.$linter_name);
    }

    $remaining_errors = Vec\filter($errors, $e ==> !$e->isIgnored());
    if (!C\is_empty($remaining_errors)) {
      throw new \Exception(
        'The following error was not ignored: '.
        $remaining_errors[0]->toString(),
      );
    }
  }
}
