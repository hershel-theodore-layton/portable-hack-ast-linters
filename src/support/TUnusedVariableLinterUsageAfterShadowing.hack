/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HTL\Pha;

type TUnusedVariableLinterAfterShadowing = shape(
  'is_assignment' => bool,
  'owners' => vec<Pha\Syntax>,
  'var' => Pha\Token,
  'var_name' => string,
);
