/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{Regex, Vec};
use namespace HTL\Pha;

function getter_method_could_have_a_context_list_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $pragma_map,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  $get_compound_statement_statements =
    Pha\create_member_accessor($script, Pha\MEMBER_COMPOUND_STATEMENTS);
  $get_function_contexts =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_CONTEXTS);
  $get_function_name =
    Pha\create_member_accessor($script, Pha\MEMBER_FUNCTION_NAME);
  $get_method_decl_header = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_METHODISH_FUNCTION_DECL_HEADER,
  )
    |> Pha\returns_syntax($$);
  $get_method_body =
    Pha\create_member_accessor($script, Pha\MEMBER_METHODISH_FUNCTION_BODY);
  $get_return_expression =
    Pha\create_member_accessor($script, Pha\MEMBER_RETURN_EXPRESSION);

  $is_compound_statement =
    Pha\create_syntax_matcher($script, Pha\KIND_COMPOUND_STATEMENT);
  $is_return_statement =
    Pha\create_syntax_matcher($script, Pha\KIND_RETURN_STATEMENT);

  return
    Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_METHODISH_DECLARATION)
    |> Vec\filter($$, $m ==> {
      $header = $get_method_decl_header($m);

      if (!Pha\is_missing($get_function_contexts($header))) {
        return false;
      }

      $function_name = $get_function_name($header)
        |> Pha\node_get_code_compressed($script, $$);

      if (!Regex\matches($function_name, re'/^(get|has|is)[A-Z]/')) {
        return false;
      }

      $method_body = $get_method_body($m);

      if (!$is_compound_statement($method_body)) {
        return false;
      }

      $first_statement = $method_body
        |> Pha\as_syntax($$)
        |> $get_compound_statement_statements($$)
        |> Pha\node_get_first_child($script, $$);

      if (!$is_return_statement($first_statement)) {
        return false;
      }

      return $first_statement
        |> Pha\as_syntax($$)
        |> $get_return_expression($$)
        |> Pha\node_get_code_compressed($script, $$)
        // This is a rather crude heuristic.
        // It matches `$this->it`, `$this->it as Type`, and `$this->it is Type`.
        // The idea is to have little false positives.
        // A false negative, such as `$this->it < 6` is fine.
        // This could be a getter, but maybe this is simple
        // as an implementation detail, who knows?
        |> Regex\matches($$, re'/^\$this->(\w)+$/');
    })
    |> Vec\map(
      $$,
      $method_decl_header ==> LintError::createWithPatches(
        $script,
        $pragma_map,
        $method_decl_header,
        $linter,
        'This method is heuristically a simple getter. '.
        'Simple getters can be marked pure using the `[]` syntax. '.
        "The current heuristic is rather crude:\n".
        " - method name looks like getIt, hasIt, or isIt\n".
        " - method body is a single return statement accessing a property on \$this\n".
        'If you have a common false positive, please improve this heuristic.',
        Pha\patches(
          $script,
          Pha\patch_node(
            $method_decl_header
              |> $get_method_decl_header($$)
              |> $get_function_contexts($$),
            '[]',
            shape('trivia' => Pha\RetainTrivia::BOTH),
          ),
        ),
      ),
    );
}
