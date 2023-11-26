/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

enum ComparisonKind: int {
  EQUALS = 0;
  NOT_EQUALS = 1;
  LESS_THAN = 2;
  LESS_THAN_OR_EQUAL = 3;
  GREATER_THAN = 4;
  GREATER_THAN_OR_EQUAL = 5;
}
