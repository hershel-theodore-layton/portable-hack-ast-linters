//##! 3
namespace Linters\Tests\PreferSingleQuotedStringLiteralsLinter;

function func1(): void {
  "";
  "a";
  "\$a";
}

//##! 0
function func2(): void {
  $x = '';
  "$x";

  "\n";
  "\x12";
  "\u{2603}";
  "\0";
}
