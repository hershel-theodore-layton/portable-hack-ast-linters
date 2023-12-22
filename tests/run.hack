/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\{C, Dict, File, Math, Regex, Str, Vec};
use namespace HTL\{Pha, PhaLinters};
use function HH\fun_get_function;

<<__EntryPoint>>
async function run_async(): Awaitable<void> {
  require_once __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();
  require_once __DIR__.'/../portable-hack-ast-pre-package.tmp.hack';

  await pragma_test_async();

  $linters = vec[
    PhaLinters\async_function_and_method_linter<>,
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
    PhaLinters\concat_merge_or_union_expression_can_be_simplified_linter<>,
    PhaLinters\count_expression_can_be_simplified_linter<>,
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
    PhaLinters\no_elseif_linter<>,
    PhaLinters\no_empty_statements_linter<>,
    PhaLinters\no_final_method_in_final_classes_linter<>,
    PhaLinters\no_string_interpolation_linter<>,
    PhaLinters\no_php_equality_linter<>,
    PhaLinters\pragma_could_not_be_parsed_linter<>,
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
    PhaLinters\use_statement_without_kind_linter<>,
    PhaLinters\whitespace_linter<>,
  ]
    |> Dict\from_values($$, fun_get_function<>)
    |> Dict\map_keys(
      $$,
      $f ==> Str\slice($f, Str\search_last($f, '\\') as nonnull + 1),
    );

  $linters['license_header_linter'] = ($script, $_, $_, $_, $_)[] ==>
    PhaLinters\license_header_linter($script, '/* Example License Text */');
  $linters['pragma_prefix_unknown_linter'] = ($script, $_, $_, $_, $map)[] ==>
    PhaLinters\pragma_prefix_unknown_linter(
      $script,
      $map,
      keyset['known_prefix'],
    );

  // Some tests change their behavior on more recent versions of hhvm.
  // For example, no_elseif_linter<>, since `elseif (expression) {}` will be
  // parsed as a function call followed by a legacy curly brace subscript.
  // This is a Hack error, so reporting a lint error is not needed.
  // The version number (Mmmmpp) Major, minor, patch is the first version
  // where a 0 (rather than the stored error count) is expected.
  $tests_that_should_have_zero_errrors_on_hhvm_version = dict[
    'no_elseif_linter' => 415800,
  ];

  $test_groups = await Vec\map_async(
    \glob(__DIR__.'/examples/*.hack*'),
    async $p ==> {
      $name = Regex\first_match($p, re'#/(\w+)\.hack#') |> $$[1] ?? 'ERROR';
      $linter = idx($linters, $name);

      if ($linter is null) {
        throw new \Exception('ERROR Unknown linter: '.$name);
      }

      $file = File\open_read_only($p);
      using (
        $file->closeWhenDisposed(),
        $file->tryLockx(File\LockType::SHARED)
      ) {
        $contents = await $file->readAllAsync();
      }

      return tuple($linter, $name, $contents);
    },
  );

  // execute linters in a pure context
  list($errors, $test_count) = ()[] ==> {
    $errors = vec[];
    $test_count = 0;
    $ctx = Pha\create_context();

    foreach ($test_groups as list($linter, $linter_name, $full_file)) {
      foreach (Str\split($full_file, '//#') |> Vec\filter($$) as $test) {
        ++$test_count;
        list($script, $ctx) = Pha\parse($test, $ctx);
        $syntax_index = Pha\create_syntax_kind_index($script);
        $token_index = Pha\create_token_kind_index($script);
        $resolver = Pha\create_name_resolver(
          $script,
          $syntax_index,
          $token_index,
        );
        $pragma_map = Pha\create_pragma_map($script, $syntax_index);

        $expected_errors = Regex\every_match(
          $test,
          re'/\#! (?<err_cnt>\d+)\s/',
        );
        if (C\count($expected_errors) !== 1) {
          $errors[] = "ERROR Failed to parse error count directive: \n".$test;
          continue;
        }

        try {
          $lint_errors = $linter(
            $script,
            $syntax_index,
            $token_index,
            $resolver,
            $pragma_map,
          );
          $err_cnt = Str\to_int($expected_errors[0]['err_cnt']) as nonnull;
          if (
            \HHVM_VERSION_ID >=
              idx(
                $tests_that_should_have_zero_errrors_on_hhvm_version,
                $linter_name,
                Math\INT64_MAX,
              )
          ) {
            $err_cnt = 0;
          }

          if (C\count($lint_errors) !== $err_cnt) {
            $errors[] = Str\format(
              "ERROR Expected %d errors, got %d: %s\n%s",
              $err_cnt,
              C\count($lint_errors),
              Str\join(Vec\map($lint_errors, $e ==> $e->toString()), "\n"),
              $test,
            );
          }
        } catch (Pha\PhaException $e) {
          $errors[] = Str\format(
            "ERROR Exception: %s\nCore dump: %s",
            $e->getMessage(),
            Pha\_Private\translation_unit_reveal($script)->debugDumpHex(),
          );
        }
      }
    }

    return tuple($errors, $test_count);
  }();

  echo Str\format("Ran %d tests, %d failed.\n", $test_count, C\count($errors));

  foreach ($errors as $error) {
    echo $error."\n\n";
  }

  echo Str\format(
    "Running these tests took: %g MB of RAM\n",
    \memory_get_peak_usage(true) / 1000000,
  );

  exit(C\is_empty($errors) ? 0 : 1);
}
