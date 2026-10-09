/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\Project_qddJrbePQy2E\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:8100d3e16769118bb095'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\PhaLinters\Tests\decorator_tests<>)
    ->addTestGroupAsync(\HTL\PhaLinters\Tests\linter_fixtures_async<>)
    ->addTestGroup(\HTL\PhaLinters\Tests\pragma_tests<>)
    ->addTestGroup(\HTL\PhaLinters\Tests\source_lint_tests<>);
}
