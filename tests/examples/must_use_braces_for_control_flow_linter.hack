//##! 6
namespace Linters\Tests\MustUseBracesForControlFlowLinter;

function func1(): void {
  if (true) // hackfmt must undo the brace style
    echo 4;
  else // we must insert an extra newline
    echo 5;

  while (true) // because of single line comments
    echo 6;

  foreach ($a as $b) // which could consume the opening curly
    echo 7;

  for (; ; )
    echo 8;

  do // and break the nesting
    return;
  while (true);
}

//##! 0
function func2(): void {
  if (true) {
    echo 4;
  } else {
    while (true) {
      foreach ($a as $b) {
        for (; ; ) {
          do {
            echo 5;
          } while (true);
        }
      }
    }
  }
}

//##! 5
function nested_if_bodies(bool $x, vec<bool> $xs): void {
  while ($x) if ($x) { break; }
  for (; $x; ) if ($x) { break; }
  foreach ($xs as $v) if ($v) { break; }
  do if ($x) { break; } while ($x);
  if ($x) if ($x) { echo 'yes'; } else { echo 'no'; }
}

//##! 0
function else_if_chain(bool $x): void {
  if ($x) { echo 'a'; } else if ($x) { echo 'b'; } else { echo 'c'; }
}

//##! 2
function nested_unbraced_bodies(bool $x): void {
  while ($x) if ($x) echo 'yes'; else { echo 'no'; }
}

//##! 3
function three_nested_bodies(bool $x): void {
  while ($x) if ($x) if ($x) echo 'yes'; else { echo 'no'; }
}
