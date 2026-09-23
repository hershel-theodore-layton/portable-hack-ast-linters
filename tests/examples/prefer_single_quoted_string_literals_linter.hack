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
  "quoted \"line\n\"";
  "'\"";
  "\\n";
}

//##! 0
function escaped_quotes(): vec<string> {
  return vec[
    "say \"hi\"",
    "\"",
    "\\\"",
    "\\\\\"",
    "\q\"",
    "a\"b\"c",
    "\\\"tail\\",
    "\8\"",
  ];
}

//##! 2
function escaped_backslashes(): vec<string> {
  return vec[
    "\\\\",
    "tail\\",
  ];
}
