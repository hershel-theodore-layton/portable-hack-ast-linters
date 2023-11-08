/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

enum UseKind: int {
  CONST = 0;
  FUNCTION = 1;
  NAMESPACE = 2;
  TYPE = 3;
  NONE = 4;
}

const vec<UseKind> REAL_USE_KINDS =
  vec[UseKind::CONST, UseKind::FUNCTION, UseKind::NAMESPACE, UseKind::TYPE];
