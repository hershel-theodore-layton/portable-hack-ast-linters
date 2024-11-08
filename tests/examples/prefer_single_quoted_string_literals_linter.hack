//##! 2
namespace Linters\Tests\PreferSingleQuotedStringLiteralsLinter;

function func1(): void {
  "";
  /*1*/"a"/*2*/;
}

//##! 0
function func2(): void {
  $x = '';
  "$x";

  "\n";
  "\x12";
  "\u{2603}";
  "\0";
  "\$a";
}
