# portable-hack-ast-linters

_Hack source code linters authored with portable-hack-ast_

## How to lint my code

If you've used [HHAST](https://github.com/hhvm/hhast) before, you might expect
that you'd be able to add a `hhast-lint.json` or alike to your repository to
start linting right away. PhaLinters **does not work this way**. You must add a
Hack source code file which does the linting and call the linters directly.
The linters are in the `HTL\PhaLinters` namespace, so autocomplete away.

This library lints itself. You can check [lint.hack](./tests/lint.hack)
and copy it verbatim. This file is explicitly licensed as
[MIT-0](https://choosealicense.com/licenses/mit-0/), not MIT like the rest of
this library. This means you can do all the things permitted by the MIT license,
without having to keep the license comment in the file intact.
_This choice of license does not change the license for the rest of this project._

## Which linters are included?

For the full list, see [bundled linters](./BUNDLED_LINTERS.md), almost all linters from HHAST are included, and some never before seen linters, only available in portable-hack-ast-linters.

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
Compilers don’t read comments ...
and neither do many programmers (consistently).
```

As a replacement for fixme comments, PhaLinters uses the `pragma(...)` directive
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
