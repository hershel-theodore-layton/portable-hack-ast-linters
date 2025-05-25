/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH;
use namespace HH\Lib\{C, Dict, File, Math, OS, Regex, Str, Vec};
use namespace HTL\{Pha, PhaLinters};
use function HH\fun_get_function;

<<__EntryPoint>>
async function run_async()[defaults]: Awaitable<void> {
  $autoloader = __DIR__.'/../vendor/autoload.hack';
  if (HH\could_include($autoloader)) {
    require_once $autoloader;
    HH\dynamic_fun('Facebook\AutoloadMap\initialize')();
  }

  await pragma_test_async();

  $linters = vec[
    PhaLinters\async_function_and_method_linter<>,
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
    PhaLinters\concat_merge_or_union_expression_can_be_simplified_linter<>,
    PhaLinters\context_list_must_be_explicit_linter<>,
    PhaLinters\context_list_must_be_explicit_on_io_functions_linter<>,
    PhaLinters\count_expression_can_be_simplified_linter<>,
    PhaLinters\dont_await_in_a_loop_linter<>,
    PhaLinters\dont_create_forwarding_lambdas_linter<>,
    PhaLinters\dont_discard_new_expressions_linter<>,
    PhaLinters\dont_use_asio_join_linter<>,
    PhaLinters\final_or_abstract_classes_linter<>,
    PhaLinters\generated_file_may_not_be_modified_manually_linter<>,
    PhaLinters\getter_method_could_have_a_context_list_linter<>,
    PhaLinters\group_use_statement_alphabetization_linter<>,
    PhaLinters\group_use_statements_linter<>,
    PhaLinters\lambda_parameter_list_parentheses_can_be_removed_linter<>,
    PhaLinters\must_use_braces_for_control_flow_linter<>,
    PhaLinters\namespace_private_symbol_linter<>,
    PhaLinters\namespace_private_use_clause_linter<>,
    PhaLinters\no_elseif_linter<>,
    PhaLinters\no_empty_statements_linter<>,
    PhaLinters\no_final_method_in_final_classes_linter<>,
    PhaLinters\no_string_interpolation_linter<>,
    PhaLinters\no_php_equality_linter<>,
    PhaLinters\no_newline_at_start_of_control_flow_block_linter<>,
    PhaLinters\pragma_could_not_be_parsed_linter<>,
    PhaLinters\prefer_lambdas_linter<>,
    PhaLinters\prefer_single_quoted_string_literals_linter<>,
    PhaLinters\prefer_require_once_linter<>,
    PhaLinters\shout_case_enum_members_linter<>,
    PhaLinters\solitary_escape_sequences_should_be_disambiguated_linter<>,
    PhaLinters\unreachable_code_linter<>,
    PhaLinters\unused_pipe_variable_linter<>,
    PhaLinters\unused_use_clause_linter<>,
    PhaLinters\unused_variable_linter<>,
    PhaLinters\use_statement_with_as_linter<>,
    PhaLinters\use_statement_with_leading_backslash_linter<>,
    PhaLinters\use_statement_without_kind_linter<>,
    PhaLinters\variable_name_must_be_lowercase_linter<>,
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
  $linters['pragma_prefix_unknown_linter'] = ($script, $_, $_, $_, $map)[] ==>
    PhaLinters\pragma_prefix_unknown_linter(
      $script,
      $map,
      keyset['known_prefix'],
    );
  $linters['shape_type_additional_field_intent_should_be_explicit_linter'] = (
    $script,
    $syntax_index,
    $_,
    $_,
    $pragma_map,
  )[] ==>
    PhaLinters\shape_type_additional_field_intent_should_be_explicit_linter(
      $script,
      $syntax_index,
      $pragma_map,
      '/*_*/',
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
    Vec\concat(
      \glob(__DIR__.'/examples/*.hack'),
      \glob(__DIR__.'/examples/*.hack.invalid'),
    ),
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

      try {
        $autofix_file = File\open_read_only($p.'.autofix');
        using (
          $autofix_file->closeWhenDisposed(),
          $autofix_file->tryLockx(File\LockType::SHARED)
        ) {
          $autofix_contents = await $autofix_file->readAllAsync();
        }
      } catch (OS\NotFoundException $e) {
        $autofix_contents = null;
      }

      return tuple($linter, $name, $contents, $autofix_contents);
    },
  );

  // execute linters in a pure context
  list($errors, $test_count) = ()[] ==> {
    $errors = vec[];
    $test_count = 0;
    $ctx = Pha\create_context();

    foreach (
      $test_groups as
        $test_number => list($linter, $linter_name, $full_file, $autofix)
    ) {
      foreach (Str\split($full_file, '//#') |> Vec\filter($$) as $test) {
        ++$test_count;
        list($script, $ctx) = Pha\parse($test, $ctx);
        $syntax_index = Pha\create_syntax_kind_index($script);
        $token_index = Pha\create_token_kind_index($script);
        $resolver =
          Pha\create_name_resolver($script, $syntax_index, $token_index);
        $pragma_map = Pha\create_pragma_map($script, $syntax_index);

        $expected_errors =
          Regex\every_match($test, re'/\#! (?<err_cnt>\d+)\s/');
        if (C\count($expected_errors) !== 1) {
          $errors[] = "ERROR Failed to parse error count directive: \n".$test;
          continue;
        }

        $expected = C\onlyx($expected_errors);

        try {
          $lint_errors = $linter(
            $script,
            $syntax_index,
            $token_index,
            $resolver,
            $pragma_map,
          );
          $err_cnt = Str\to_int($expected['err_cnt']) as nonnull;
          $should_be_a_noop = \HHVM_VERSION_ID >=
            idx(
              $tests_that_should_have_zero_errrors_on_hhvm_version,
              $linter_name,
              Math\INT64_MAX,
            );
          if ($should_be_a_noop) {
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

          $patches = Vec\map($lint_errors, $e ==> $e->getPatches())
            |> Vec\filter_nulls($$);

          if ($autofix is null) {
            $errors[] = Str\format(
              "ERROR Expected an autofix file for %s\n",
              $linter_name,
            );
            continue;
          }

          $autofixed = !C\is_empty($patches)
            ? Pha\patches_combine_without_conflict_resolution($patches)
              |> Pha\patches_apply($$)
            : Pha\node_get_code($script, Pha\SCRIPT_NODE);

          if (!Str\contains($autofix, $autofixed) && !$should_be_a_noop) {
            $errors[] = Str\format(
              "The autofix for test %s:%d was not found in the autofix file.\n%s\n",
              $linter_name,
              $test_number,
              $autofixed,
            );
          }
        } catch (Pha\PhaException $e) {
          $errors[] = Str\format(
            "ERROR Exception: %s\nCore dump: %s",
            $e->getMessage(),
            Pha\node_get_code($script, Pha\SCRIPT_NODE),
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
    \memory_get_peak_usage(true) / 1000000.,
  );

  exit(C\is_empty($errors) ? 0 : 1);
}
