//##! 3
namespace Linters\Tests\SolitaryEscapeSequencesShouldBeDisambiguated;

const string X1 = '\n';
const string X2 = /*1*/ '\r'/*2*/;
const string X3 = '\0';

//##! 0
const string X4 = 'Hi\n';
const string X5 = '\y';
const string X6 = '\\n';
const string X7 = '\\r';
