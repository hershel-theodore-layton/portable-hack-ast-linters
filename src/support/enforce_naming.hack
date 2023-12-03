/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters\Support;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

function enforce_naming(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  (function(string, Pha\Syntax)[_]: bool) $function_name_func,
  (function(string, Pha\Syntax)[_]: bool) $method_name_func,
  ?vec<string> $allowed_suffixes = null,
)[ctx $function_name_func, ctx $method_name_func]: vec<Pha\Syntax> {
  $allowed_suffixes ??= vec[
    '__DEPRECATED',
    '__DO_NOT_USE',
    '__UNTYPED',
    '__UNSAFE',
    '_DEPRECATED',
    '_DO_NOT_USE',
    '_UNTYPED',
    '_UNSAFE',
  ];

  $is_function_declaration =
    Pha\create_syntax_matcher($script, Pha\KIND_FUNCTION_DECLARATION);

  $get_function_name =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_NAME);

  $get_function_name_as_text = $decl ==> $get_function_name($decl)
    |> Pha\as_token($$)
    |> Pha\token_get_text($script, $$)
    |> C\reduce($allowed_suffixes, Str\strip_suffix<>, $$);

  list($function_decls, $method_decls) = Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_FUNCTION_DECLARATION_HEADER,
  )
    |> Vec\partition(
      $$,
      $h ==> $is_function_declaration(Pha\node_get_parent($script, $h)),
    );

  return Vec\concat(
    Vec\filter(
      $function_decls,
      $d ==> $function_name_func($get_function_name_as_text($d), $d),
    ),
    Vec\filter(
      $method_decls,
      $d ==> $method_name_func($get_function_name_as_text($d), $d),
    ),
  );
}
