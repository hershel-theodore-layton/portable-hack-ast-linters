//##! 3
namespace Linters\Tests\PragmaPrefixUnknownLinter;

use type HTL\Pragma\Pragmas;
use function HTL\Pragma\pragma;

<<file: Pragmas(vec['known_prefix', 'ok=1'], vec['unknown_prefix', 'ok=0'])>>

<<Pragmas(vec['known_prefix', 'ok=1'], vec['unknown_prefix', 'ok=0'])>>
function func1(): void {
  pragma('known_prefix', 'ok=1');
  pragma('unknown_prefix', 'ok=0');
}
