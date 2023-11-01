/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HH\Lib\{C, Dict, File, Regex, Str, Vec};
use namespace HTL\{Pha, PhaLinters};
use function HH\fun_get_function;

<<__EntryPoint>>
async function run_async(): Awaitable<void> {
  $linters = vec[
    PhaLinters\prefer_require_once_linter<>,
  ]
    |> Dict\from_values($$, fun_get_function<>)
    |> Dict\map_keys(
      $$,
      $f ==> Str\slice($f, Str\search_last($f, '\\') as nonnull + 1),
    );

  $linter_sources_pairs = await Vec\map_async(
    \glob(__DIR__.'/examples/*.hack'),
    async $p ==> {
      $name = Regex\first_match($p, re'#/(\w+)\.hack$#') |> $$[1] ?? 'ERROR';
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

      return tuple($linter, $contents);
    },
  );

  // execute linters in a pure context
  list($errors, $test_count) = ()[] ==> {
    $errors = vec[];
    $test_count = 0;
    $ctx = Pha\create_context();

    foreach ($linter_sources_pairs as list($linter, $full_file)) {
      foreach (Str\split($full_file, '//#') |> Vec\filter($$) as $test) {
        ++$test_count;
        list($script, $ctx) = Pha\parse($test, $ctx);
        $index = Pha\create_syntax_kind_index($script);

        $expected_errors =
          Regex\every_match($test, re'/\#! (?<err_cnt>\d+)\s/');
        if (C\count($expected_errors) !== 1) {
          $errors[] = "ERROR Failed to parse error count directive: \n".$test;
          continue;
        }

        try {
          $lint_errors = $linter($script, $index);
          $err_cnt = Str\to_int($expected_errors[0]['err_cnt']) as nonnull;

          if (C\count($lint_errors) !== $err_cnt) {
            $errors[] = Str\format(
              "ERROR Expected %d errors, got %d: %s\n%s",
              $err_cnt,
              C\count($lint_errors),
              Str\join(Vec\map($lint_errors, $e ==> $e->toString()), "\n"),
              $test,
            );
          }
        } catch (\ExceptionWithPureGetMessage $e) {
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
    \memory_get_peak_usage(true) / 1_000_000,
  );
}
