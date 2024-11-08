/**
 * You are encouraged to copy paste this file and change it to meet your needs.
 * From the moment you make a single edit to this file, f.e. a change to the
 * namespace name, your version of this file becomes yours and yours alone.
 * The unedited original remains licensed under MIT-0.
 * This license text is included at the bottom of this file.
 *
 * The license at the end of this file applies to this file and this file alone.
 * The license of the other files in this project remains unaffected.
 */

namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\{File, IO, Str, Vec};
use namespace HTL\{Pha, PhaLinters};
use type HTL\Pragma\Pragmas;
use function HTL\Pragma\pragma;
use function glob, realpath;

<<file: Pragmas(vec['PhaLinters', 'fixme:license_header'])>>

type TLinter = (function(
  Pha\Script,
  Pha\SyntaxIndex,
  Pha\TokenIndex,
  Pha\Resolver,
  Pha\PragmaMap,
)[]: vec<PhaLinters\LintError>);

// This entrypoint can be run from a cli or a web-server.
// For the best performance results, run this in a web-server in repo-auth mode.
<<__EntryPoint>>
async function lint_async(): Awaitable<void> {
  require_once __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  $linters = get_linters();
  $files = await get_files_async();
  $ctx = Pha\create_context();
  $stdout = IO\request_output();

  $ok = true;
  foreach ($files as $file) {
    $path = $file['path'];

    list($script, $ctx) = Pha\parse($file['contents'], $ctx);
    $syntax_index = Pha\create_syntax_kind_index($script);
    $token_index = Pha\create_token_kind_index($script);
    $resolver = Pha\create_name_resolver($script, $syntax_index, $token_index);
    $pragma_map = Pha\create_pragma_map($script, $syntax_index);

    $error_text = Vec\map(
      $linters,
      $l ==> $l($script, $syntax_index, $token_index, $resolver, $pragma_map),
    )
      |> Vec\flatten($$)
      |> Vec\filter($$, $e ==> !$e->isIgnored())
      |> Vec\map($$, $e ==> Str\format("%s in %s\n", $e->toString(), $path))
      |> Str\join($$, '');

    $has_errors = Str\length($error_text) !== 0;
    $ok = $ok && !$has_errors;
    if ($has_errors) {
      // await-in-a-loop, yield errors often and early.
      // The developer is waiting for this output!
      pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
      await $stdout->writeAllAsync($error_text);
    }
  }

  if ($ok) {
    await $stdout->writeAllAsync(Str\format(
      "Memory peak usage: %g MiB\n",
      \memory_get_peak_usage(true) / (1024 * 1024),
    ));
  }

  await $stdout->writeAllAsync($ok ? "No errors!\n" : "Get fixin'!\n");
  exit($ok ? 0 : 1);
}

function get_linters()[]: vec<TLinter> {
  $expected_license_header =
    '/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */';
  $known_pragma_prefixes = keyset['PhaLinters'];

  $linters = vec[
    PhaLinters\async_function_and_method_linter<>,
    PhaLinters\camel_cased_methods_underscored_functions_linter<>,
    PhaLinters\concat_merge_or_union_expression_can_be_simplified_linter<>,
    PhaLinters\context_list_must_be_explicit_linter<>,
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
    PhaLinters\no_newline_at_start_of_control_flow_block_linter<>,
    PhaLinters\no_php_equality_linter<>,
    PhaLinters\no_string_interpolation_linter<>,
    PhaLinters\pragma_could_not_be_parsed_linter<>,
    PhaLinters\prefer_lambdas_linter<>,
    PhaLinters\prefer_require_once_linter<>,
    PhaLinters\prefer_single_quoted_string_literals_linter<>,
    PhaLinters\shout_case_enum_members_linter<>,
    PhaLinters\solitary_escape_sequences_should_be_disambiguated_linter<>,
    PhaLinters\unreachable_code_linter<>,
    PhaLinters\unused_pipe_variable_linter<>,
    PhaLinters\unused_use_clause_linter<>,
    PhaLinters\unused_variable_linter<>,
    PhaLinters\use_statement_with_as_linter<>,
    PhaLinters\use_statement_with_leading_backslash_linter<>,
    PhaLinters\use_statement_without_kind_linter<>,
    PhaLinters\whitespace_linter<>,
  ];

  $linters[] = ($script, $_, $_, $_, $pragma_map) ==>
    PhaLinters\license_header_linter(
      $script,
      $pragma_map,
      $expected_license_header,
    );
  $linters[] = ($script, $_, $_, $_, $pragma_map) ==>
    PhaLinters\pragma_prefix_unknown_linter(
      $script,
      $pragma_map,
      $known_pragma_prefixes,
    );
  $linters[] = ($script, $syntax_index, $_, $_, $pragma_map) ==>
    PhaLinters\shape_type_additional_field_intent_should_be_explicit_linter(
      $script,
      $syntax_index,
      $pragma_map,
      '// @closed-shape',
    );

  return $linters;
}

function get_files_async(
): Awaitable<vec<shape('path' => string, 'contents' => string)>> {
  $base_dir = __DIR__.'/../src/';
  return Vec\concat(
    glob($base_dir.'*.hack'),
    glob($base_dir.'*/*.hack'),
    glob($base_dir.'*/*/*.hack'),
    glob($base_dir.'*/*/*/*.hack'),
    glob($base_dir.'*/*/*/*/*.hack'),
    glob($base_dir.'*/*/*/*/*/*.hack'),
    glob($base_dir.'*/*/*/*/*/*/*.hack'),
    glob($base_dir.'*/*/*/*/*/*/*/*.hack'),
  )
    |> Vec\map_async(
      $$,
      async $path ==> {
        $file = File\open_read_only($path);
        using $file->closeWhenDisposed();
        using $file->tryLockx(File\LockType::SHARED);
        return shape(
          'path' => realpath($path),
          'contents' => await $file->readAllAsync(),
        );
      },
    );
}

/*
 * This license notice NEED NOT be preserved.
 *                     ^^^^^^^^
 * MIT No Attribution
 * 
 * Copyright 2024 Hershel Theodore Layton
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
