/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

enum CallingCovention: int {
  PLAIN = 0;
  INOUT = 1;
  VARIADIC = 2;
  OTHER = 3;
}
