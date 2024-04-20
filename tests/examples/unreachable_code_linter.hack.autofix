//##! 4
namespace Linters\Tests\UnreachableCodeLinter;

function func1(): void {
  for (; ; ) {
    break;
    0;
  }

  for (; ; ) {
    continue;
    0;
  }

  switch (1) {
    case 1:
      break;
      0;
    default:
  }

  return;
  0;
}

//##! 0

function func2(): void {
  return;
}
