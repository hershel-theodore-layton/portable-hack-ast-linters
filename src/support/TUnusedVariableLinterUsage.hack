/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HTL\Pha;

type TUnusedVariableLinterUsage = shape(
  'is_assignment' => bool,
  'param_of_func' => Pha\NillableSyntax,
  'param_of_lambda' => Pha\NillableSyntax,
  'scopes' => vec<Pha\Syntax>,
  'var' => Pha\Token,
  'var_name' => string,
  /*_*/
);
