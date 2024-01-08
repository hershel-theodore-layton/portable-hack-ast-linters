# portable-hack-ast-linters

_Hack source code linters authored with portable-hack-ast_

## How to lint my code

If you've used [HHAST](https://github.com/hhvm/hhast) before, you might expect
that you'd be able to add a `hhast-lint.json` or alike to your repository to
start linting right away. PhaLinters **does not work this way**. You must add a
Hack source code file which does the linting and call the linters directly.
The linters are in the `HTL\PhaLinters` namespace, so autocomplete away.

This library (TODO) lints itself. You can check [lint.hack](./tests/lint.hack)
and copy it verbatim. This file is explicitly licensed as
[MIT-0](https://choosealicense.com/licenses/mit-0/), not MIT like the rest of
this library. This means you can do all the things permitted by the MIT license,
without having to keep the license comment in the file intact.
_This choice of license does not change the license for the rest of this project._

## Which linters are included?

### HHAST adapted linters

If you've used HHAST before, many of these linters will look familiar. Many of
them are a great idea, and a couple have been kept for backwards compatibility
purposes.

The following linters share functionality with linters bundled with HHAST:

- [async_function_and_method_linter](./src/linters/hhast_adapted/async_function_and_method_linter.hack)
  - [AsyncFunctionAndMethodLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/AsyncFunctionAndMethodLinter.hack)
- [camel_cased_methods_underscored_functions_linter](./src/linters/hhast_adapted/camel_cased_methods_underscored_functions_linter.hack)
  - [CamelCasedMethodsUnderscoredFunctionsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/CamelCasedMethodsUnderscoredFunctionsLinter.hack)
- [dont_await_in_a_loop_linter](./src/linters/hhast_adapted/dont_await_in_a_loop_linter.hack)
  - [DontAwaitInALoopLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DontAwaitInALoopLinter.hack)
- [dont_create_forwarding_lambdas_linter](./src/linters/hhast_adapted/dont_create_forwarding_lambdas_linter.hack)
  - [DontCreateForwardingLambdasLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DontCreateForwardingLambdasLinter.hack)
- [dont_discard_new_expressions_linter](./src/linters/hhast_adapted/dont_discard_new_expressions_linter.hack)
  - [DontDiscardNewExpressionsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DontDiscardNewExpressionsLinter.hack)
- [dont_use_asio_join_linter](./src/linters/hhast_adapted/dont_use_asio_join_linter.hack)
  - [DontUseAsioJoinLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DontUseAsioJoinLinter.hack)
- [final_or_abstract_classes_linter](./src/linters/hhast_adapted/final_or_abstract_classes_linter.hack)
  - [FinalOrAbstractClassLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/FinalOrAbstractClassLinter.hack)
- [group_use_statement_alphabetization_linter](./src/linters/hhast_adapted/group_use_statement_alphabetization_linter.hack)
  - [GroupUseStatementAlphabetizationLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/GroupUseStatementAlphabetizationLinter.hack)
- [group_use_statements_linter](./src/linters/hhast_adapted/group_use_statements_linter.hack)
  - [GroupUseStatementsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/GroupUseStatementsLinter.hack)
- [license_header_linter](./src/linters/hhast_adapted/license_header_linter.hack)
  - [LicenseHeaderLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/LicenseHeaderLinter.hack)
- [must_use_braces_for_control_flow_linter](./src/linters/hhast_adapted/must_use_braces_for_control_flow_linter.hack)
  - [MustUseBracesForControlFlowLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/MustUseBracesForControlFlowLinter.hack)
- [namespace_private_symbol_linter](./src/linters/hhast_adapted/namespace_private_symbol_linter.hack)
  - [NamespacePrivateLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NamespacePrivateLinter.hack)
- [namespace_private_use_clause_linter](./src/linters/hhast_adapted/namespace_private_use_clause_linter.hack)[^1]
  - [NamespacePrivateLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NamespacePrivateLinter.hack)
- [no_elseif_linter](./src/linters/hhast_adapted/no_elseif_linter.hack)
  - [NoElseifLinter](https://github.com/hhvm/hhast/blob/c5c6208af1be5cd6ec39fc73d68558d4c9a4a62d/src/Linters/NoElseifLinter.hack)
- [no_empty_statements_linter](./src/linters/hhast_adapted/no_empty_statements_linter.hack)
  - [NoEmptyStatementsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoEmptyStatementsLinter.hack)
- [no_final_method_in_final_classes_linter](./src/linters/hhast_adapted/no_final_method_in_final_classes_linter.hack)
  - [NoFinalMethodInFinalClassLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoFinalMethodInFinalClassLinter.hack)
- [no_php_equality_linter](./src/linters/hhast_adapted/no_php_equality_linter.hack)
  - [NoPHPEqualityLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoPHPEqualityLinter.hack)
- [no_string_interpolation_linter](./src/linters/hhast_adapted/no_string_interpolation_linter.hack)
  - [NoStringInterpolationLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoStringInterpolationLinter.hack)
- [prefer_lambdas_linter](./src/linters/hhast_adapted/prefer_lambdas_linter.hack)
  - [PreferLambdasLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/PreferLambdasLinter.hack)
- [prefer_require_once_linter](./src/linters/hhast_adapted/prefer_require_once_linter.hack)
  - [PreferRequireOnceLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/PreferRequireOnceLinter.hack)
- [prefer_single_quoted_string_literals_linter](./src/linters/hhast_adapted/prefer_single_quoted_string_literals_linter.hack)
  - [PreferSingleQuotedStringLiteralLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/PreferSingleQuotedStringLiteralLinter.hack)
- [shout_case_enum_members_linter](./src/linters/hhast_adapted/shout_case_enum_members_linter.hack)
  - [ShoutCaseEnumMembersLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/ShoutCaseEnumMembersLinter.hack)
- [unreachable_code_linter](./src/linters/hhast_adapted/unreachable_code_linter.hack)
  - [UnreachableCodeLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnreachableCodeLinter.hack)
- [unused_pipe_variable_linter](./src/linters/hhast_adapted/unused_pipe_variable_linter.hack)
  - [UnusedPipeVariableLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnusedPipeVariableLinter.hack)
- [unused_use_clause_linter](./src/linters/hhast_adapted/unused_use_clause_linter.hack)
  - [UnusedUseClauseLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnusedUseClauseLinter.hack)
- [unused_variable_linter](./src/linters/hhast_adapted/unused_variable_linter.hack)
  - [UnusedLambdaParameterLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnusedLambdaParameterLinter.hack)
  - [UnusedParameterLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnusedParameterLinter.hack)
  - [UnusedVariableLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UnusedVariableLinter.hack)
- [use_statement_with_as_linter](./src/linters/hhast_adapted/use_statement_with_as_linter.hack)
  - [UseStatementWithAsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UseStatementWithAsLinter.hack)
- [use_statement_with_leading_backslash_linter](./src/linters/hhast_adapted/use_statement_with_leading_backslash_linter.hack)
  - [UseStatementWithLeadingBackslashLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UseStatementWithLeadingBackslashLinter.hack)
- [use_statement_without_kind_linter](./src/linters/hhast_adapted/use_statement_without_kind_linter.hack)
  - [UseStatementWIthoutKindLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/UseStatementWIthoutKindLinter.hack)
- [whitespace_linter](./src/linters/hhast_adapted/whitespace_linter.hack)
  - [ConsistentLineEndingsLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/ConsistentLineEndingsLinter.hack)
  - [DontHaveTwoEmptyLinesInARowLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DontHaveTwoEmptyLinesInARowLinter.hack)
  - [NewlineAtEndOfFileLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NewlineAtEndOfFileLinter.hack)
  - [NoNewlineAtStartOfControlFlowBlockLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoNewlineAtStartOfControlFlowBlockLinter.hack)
  - [NoWhitespaceAtEndOfLineLinter](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/NoWhitespaceAtEndOfLineLinter.hack)

### Pha native linters

There are also a couple of completely new linters (you can't get these in hhast).
They can be found in the [pha_native](./src/linters/pha_native) directory:

- [concat_merge_or_union_expression_can_be_simplified_linter](./src/linters/pha_native/concat_merge_or_union_expression_can_be_simplified_linter.hack)
- [count_expression_can_be_simplified_linter](./src/linters/pha_native/count_expression_can_be_simplified_linter.hack)
- [pragma_could_not_be_parsed_linter](./src/linters/pha_native/pragma_could_not_be_parsed_linter.hack)
- [pragma_prefix_unknown_linter](./src/linters/pha_native/pragma_prefix_unknown_linter.hack)

_This list may become incomplete when new linters are added in [the pha_native directory](./src/linters/pha_native)_
_and I forget to update this README. Issues and PRs welcome._

### Missing linters from HHAST

Some linters from HHAST are not included in this library.

- [HHClientLinter.hack](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/HHClientLinter.hack)
  - This linter does not use the HHAST framework. It is a wrapper around the
    `hh_client --lint` cli. The lints that `hh_client` suggest are very high
    quality and can/do utilize type information. The HHAST implementation has
    [serious performance problems](https://github.com/hhvm/hhast/issues/432).
    A separate tool could be developed, since it doesn't need anything from
    HHAST (or Pha for that matter).
- [DataProviderTypesLinter.hack](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/DataProviderTypesLinter.hack)
  - This linter was a well intentioned attempt at making `<<DataProvider(...)>>`
    annotations typesafe. By its nature, it is a crude heuristic based
    approximation of a typechecker. It suggests you do things that are actively
    harmful like abusing the `nothing` type. The "real" solution is to the
    change the `<<DataProvider>>` mechanism to complement the Hack language.
- [MustUseOverrideAttributeLinter.hack](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/MustUseOverrideAttributeLinter.hack)
  - The output of this linter depends not just on the arguments, but on global information.
    A change in a parent class will require a file to be linted again.
    Caching lint results in a cross request manner would require extensive dependency tracking.
    `hh_client --lint` does the job of this linter better and doesn't depend on the `\ReflectionClass` api.
- [StrictModeOnlyLinter.hack](https://github.com/hhvm/hhast/blob/v4.168.3/src/Linters/StrictModeOnlyLinter.hack)
  - This linter was needed in the early days of Hack.
    Files used to have the `.php` or `.hh` extension and the mode was determined by a comment.
    `<?hh` would "kick your `.php` file into Hack partial mode".
    You'd explicitly enable "strict mode" by using `<?hh // strict`.
    Since the release of [hhvm version 4.0](https://hhvm.com/blog/2019/02/11/hhvm-4.0.0.html) you can use `.hack` files.

## Fixme directives

Lint errors can't (and shouldn't) always be fixed. Sometimes an await-in-a-loop
isn't a sign of a false dependency for example in [sgml-stream's ConcurrentReusableRenderer](https://github.com/hershel-theodore-layton/sgml-stream/blob/65da582da8e5a7c363d9017158f68733f2a417e2/src/rendering/ConcurrentReusableRenderer.hack):

```HACK
async function consider_the_following_code_async(): void {
  $awaitables = vec[];
  foreach ($snippets as $snippet) {
    $awaitables[] = $snippet->primeAsync($descendant_flow);
  }

  concurrent {
    // Race them all,...
    await AwaitAllWaitHandle::fromVec($awaitables);
    await async {
      foreach ($snippets as $snippet) {
        /* HHAST_IGNORE_ERROR[DontAwaitInALoop]
         * feedBytesToConsumer operates on the awaitables from the race.
         * There are no false dependencies here.
         * We just MUST collect bytes in order. */
        await $snippet->feedBytesToConsumerAsync($consumer, $successor_flow);
      }
    };
  }
}
```

The `$snippet->feedBytesToConsumerAsync(...)` method awaits an Awaitable that
was already started in `->primeAsync(...)`. Internally, it also awaits on
`$consumer->consumeAsync(...)` which must be called sequentially.
This await-in-a-loop is required for the code to work correctly.
To inform hhast, a `HHAST_IGNORE_ERROR[DontAwaitInALoop]` comment was added.

This comment-to-suppress-a-lint-error mechanism has always bothered me a little.
I subscribe wholehartedly to the following quote from the [CppCoreGuidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines):

```
Compilers don’t read comments ... and neither do many programmers (consistently).
```

As a replacement to fixme comments, PhaLinters uses the `pragma(...)` directive
and the `<<Pragmas(...)>>` annotation. The following pieces of code express the
same intent.

```
/// hack
/* HHAST_FIXME_ERROR[DontAwaitInALoop] I'll get around to it. */
await $object->methodAsync();

// I'll get around to it.
pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
await $object->methodAsync();
```

[^1]:
    This linter works in tandem with `namespace_private_symbol_linter`.
    If the namespace use clause is already clearly `_Private`, you'll
    get lint errors early.
