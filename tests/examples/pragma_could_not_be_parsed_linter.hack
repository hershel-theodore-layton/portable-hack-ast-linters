//##! 3
namespace Linters\Tests\PragmaCouldNotBeParsedLinter;

use type HTL\Pragma\Pragmas;
use function HTL\Pragma\pragma;

<<file:
  Pragmas(
    vec['PhaLinters', 'enable:bad'],
    vec['PhaLinters', 'fixme:good'],
  )>>

<<Pragmas(vec['PhaLinters', 'enable:bad'], vec['PhaLinters', 'fixme:good'])>>
function func1(): void {
  pragma('PhaLinters', 'enable:bad');
  pragma('PhaLinters', 'fixme:good');
}
