//##! 0
namespace Linters\Tests\DontAwaitInALoopLinter;

async function func1_async(): Awaitable<vec<int>> {
  await func1_async();

  foreach (await func1_async() as $_) {
  }

  for ($x = await func1_async(); ; ) {
  }

  return vec[];
}

//##! 4 classic await in a loop

async function func2_async(): Awaitable<void> {
  for (; ; ) {
    await func2_async();
  }

  foreach (vec[] as $_) {
    await func2_async();
  }

  while (true) {
    await func2_async();
  }

  do {
    await func2_async();
  } while (true);
}

//##! 0 Await in inner lambda / async block

async function func3_async(): Awaitable<void> {
  for (; ; ) {
    $l = async () ==> {
      await func3_async();
    };

    $aw = async {
      await func3_async();
    };
  }
}
