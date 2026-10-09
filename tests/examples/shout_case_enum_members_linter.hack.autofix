//##! 3
namespace Linters\Tests\ShoutCaseEnumMemberLinter;

enum X1: int {
  snake_case = 0;
  camelCase = 1;
  PascalCase = 2;
}

//##! 0

enum X2: int {
  SHOUT_CASE = 0;
}

//##! 3

enum class X3: int {
  int snake_case = 0;
  int camelCase = 1;
  int PascalCase = 2;
}

//##! 0

enum class X4: int {
  int SHOUT_CASE = 0;
}

//##! 2

abstract enum class X5: int {
  abstract int camelCase;
  int snake_case = 0;
}

//##! 0

abstract enum class X6: int {
  abstract int SHOUT_CASE;
  int ALSO_SHOUT_CASE = 0;
}
