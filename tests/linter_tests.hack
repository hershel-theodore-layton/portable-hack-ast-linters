/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH;
use namespace HH\Lib\{C, Dict, File, OS, Regex, Str, Vec};
use namespace HTL\{Pha, PhaLinters, TestChain};
use function HH\fun_get_function;

<<TestChain\Discover>>
async function linter_fixtures_async(
  TestChain\Chain $chain,
)[defaults]: Awaitable<TestChain\Chain> {
  $linters = vec[
    PhaLinters\assignment_to_empty_list_tuple_or_shape_linter<>,
    PhaLinters\async_function_and_method_linter<>,
    PhaLinters\autoload_your_code_linter<>,
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
    PhaLinters\concat_merge_or_union_expression_can_be_simplified_linter<>,
    PhaLinters\context_list_must_be_explicit_linter<>,
    PhaLinters\context_list_must_be_explicit_on_io_functions_linter<>,
    PhaLinters\count_expression_can_be_simplified_linter<>,
    PhaLinters\dict_literal_keys_must_be_unique_linter<>,
    PhaLinters\dont_await_in_a_loop_linter<>,
    PhaLinters\dont_create_forwarding_lambdas_linter<>,
    PhaLinters\dont_discard_new_expressions_linter<>,
    PhaLinters\dont_use_asio_join_linter<>,
    PhaLinters\dont_use_hack_collections_linter<>,
    PhaLinters\final_or_abstract_classes_linter<>,
    PhaLinters\generated_file_may_not_be_modified_manually_linter<>,
    PhaLinters\getter_method_could_have_a_context_list_linter<>,
    PhaLinters\group_use_statement_alphabetization_linter<>,
    PhaLinters\group_use_statement_could_be_removed_linter<>,
    PhaLinters\group_use_statement_could_be_simplified_linter<>,
    PhaLinters\group_use_statements_linter<>,
    PhaLinters\keywords_should_be_lowercase_linter<>,
    PhaLinters\lambda_parameter_list_parentheses_can_be_removed_linter<>,
    PhaLinters\method_constant_resolves_to_enclosing_lambda_linter<>,
    PhaLinters\must_use_braces_for_control_flow_linter<>,
    PhaLinters\namespace_private_symbol_linter<>,
    PhaLinters\namespace_private_use_clause_linter<>,
    PhaLinters\negated_is_expression_does_not_need_parens_linter<>,
    PhaLinters\no_elseif_linter<>,
    PhaLinters\no_empty_statements_linter<>,
    PhaLinters\no_final_method_in_final_classes_linter<>,
    PhaLinters\no_string_interpolation_linter<>,
    PhaLinters\no_php_equality_linter<>,
    PhaLinters\no_newline_at_start_of_control_flow_block_linter<>,
    PhaLinters\pragma_could_not_be_parsed_linter<>,
    PhaLinters\prefer_lambdas_linter<>,
    PhaLinters\prefer_semicolon_bodied_namespace_linter<>,
    PhaLinters\prefer_single_quoted_string_literals_linter<>,
    PhaLinters\prefer_use_clause_over_fully_qualified_names_linter<>,
    PhaLinters\prefer_require_once_linter<>,
    PhaLinters\region_comments_must_be_balanced_linter<>,
    PhaLinters\shout_case_enum_members_linter<>,
    PhaLinters\solitary_escape_sequences_should_be_disambiguated_linter<>,
    PhaLinters\unreachable_code_linter<>,
    PhaLinters\unused_pipe_variable_linter<>,
    PhaLinters\unused_use_clause_linter<>,
    PhaLinters\unused_variable_linter<>,
    PhaLinters\use_statement_alphabetization_linter<>,
    PhaLinters\use_statement_could_be_removed_linter<>,
    PhaLinters\use_statement_order_linter<>,
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

  $test_groups = await Vec\map_async(
    Vec\concat(
      \glob(__DIR__.'/examples/*.hack') as vec<_>,
      \glob(__DIR__.'/examples/*.hack.invalid') as vec<_>,
    ),
    async $p ==> {
      $name =
        Regex\first_match($p as string, re'#/(\w+)\.hack#') |> $$[1] ?? 'ERROR';
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

      return tuple(
        $linter,
        $name,
        Str\strip_prefix($p, __DIR__.'/examples/'),
        $contents,
        $autofix_contents,
      );
    },
  );

  $chain = $chain->group(__FUNCTION__);
  foreach (
    $test_groups as
      list($linter, $linter_name, $fixture_name, $full_file, $autofix)
  ) {
    // Fixture markers are comments; region markers are not separators.
    foreach (
      Regex\split($full_file, re'~(?=//\#\#! )~') |> Vec\filter($$) as
        $case_number => $test
    ) {
      $chain = $chain->test(
        $fixture_name.':'.(string)$case_number,
        ()[] ==> assert_linter_fixture($linter, $linter_name, $test, $autofix),
      );
    }
  }
  return $chain;
}

function assert_linter_fixture(
  (function(
    Pha\Script,
    Pha\SyntaxIndex,
    Pha\TokenIndex,
    Pha\Resolver,
    Pha\PragmaMap,
  )[]: vec<PhaLinters\LintError>) $linter,
  string $linter_name,
  string $test,
  ?string $autofix,
)[]: void {
  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($test, $ctx);
  $syntax_index = Pha\create_syntax_kind_index($script);
  $token_index = Pha\create_token_kind_index($script);
  $resolver = Pha\create_name_resolver($script, $syntax_index, $token_index);
  $pragma_map = Pha\create_pragma_map($script, $syntax_index);

  $expected_errors = Regex\every_match($test, re'/\#! (?<err_cnt>\d+)\s/');
  invariant(
    C\count($expected_errors) === 1,
    "Failed to parse error count directive:\n%s",
    $test,
  );
  $expected = C\onlyx($expected_errors);
  $err_cnt = Str\to_int($expected['err_cnt']) as nonnull;
  $should_be_a_noop =
    $linter_name === 'no_elseif_linter' && \HHVM_VERSION_ID >= 415800;
  if ($should_be_a_noop) {
    $err_cnt = 0;
  }

  $lint_errors =
    $linter($script, $syntax_index, $token_index, $resolver, $pragma_map);
  invariant(
    C\count($lint_errors) === $err_cnt,
    "Expected %d errors, got %d: %s\n%s",
    $err_cnt,
    C\count($lint_errors),
    Str\join(Vec\map($lint_errors, $e ==> $e->toString()), "\n"),
    $test,
  );

  invariant(
    $autofix is nonnull,
    'Expected an autofix file for %s',
    $linter_name,
  );
  $patches = Vec\map($lint_errors, $e ==> $e->getPatches())
    |> Vec\filter_nulls($$);
  $autofixed = !C\is_empty($patches)
    ? Pha\patches_combine_without_conflict_resolution($patches)
      |> Pha\patches_apply($$)
    : Pha\node_get_code($script, Pha\SCRIPT_NODE);
  invariant(
    Str\contains($autofix, $autofixed) || $should_be_a_noop,
    "The autofix for %s was not found in the autofix file.\n%s",
    $linter_name,
    $autofixed,
  );
}
