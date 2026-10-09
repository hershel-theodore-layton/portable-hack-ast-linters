/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Tests;

use namespace HTL\TestChain;

<<TestChain\Discover>>
function source_lint_tests(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync('Project sources have no lint errors', async ()[defaults] ==> {
      invariant(
        await lint_sources_async(),
        'Project sources contain lint errors',
      );
    });
}
