//##! 1 trailing space at eol
namespace Linters\Tests\AllTheWhitespaceLinters;

const int X1 = 1; 
//##! 2 newlines at start of control flow block
function func2(): void {
  do {

    return;
  } while (true);

  if (true) {

    return;
  }
}
//##! 0 trailing space in string literal
const string X3 = <<<'EOF'
  Trailing space here: 
EOF;
//##! 1 two empty lines in a row


const int X4 = 4;
//##! 1 \r\n
const int X5 = 5;
//##! 1 no newline at eof
const int X6 = 6;//##! 0
