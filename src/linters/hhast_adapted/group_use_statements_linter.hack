/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Dict, Str, Vec};
use namespace HTL\Pha;

function group_use_statements_linter(
  Pha\Script $script,
  Pha\SyntaxIndex $syntax_index,
  Pha\TokenIndex $_,
  Pha\Resolver $_,
  Pha\PragmaMap $_,
)[]: vec<LintError> {
  $linter = __FUNCTION__;

  // If you have multiple namespaces per file, "why else use namespace blocks?",
  // this linter will ignore this file. This is no better than hhast, which will
  // report errors and suggest fixes that change the semantics: hhvm/hhast#307.
  // I have decided that I won't add in logic to support namespace nesting.
  // I won't object to a PR that adds this support.
  if (
    C\any(Pha\index_get_nodes_by_kind($syntax_index, Pha\KIND_NAMESPACE_BODY))
  ) {
    return vec[];
  }

  $is_const = Pha\create_token_matcher($script, Pha\KIND_CONST);
  $is_function = Pha\create_token_matcher($script, Pha\KIND_FUNCTION);
  $is_name = Pha\create_token_matcher($script, Pha\KIND_NAME);
  $is_namespace = Pha\create_token_matcher($script, Pha\KIND_NAMESPACE);
  $is_type = Pha\create_token_matcher($script, Pha\KIND_TYPE);

  $get_kind = Pha\create_member_accessor(
    $script,
    Pha\MEMBER_NAMESPACE_USE_KIND,
    Pha\MEMBER_NAMESPACE_GROUP_USE_KIND,
  );

  $get_grouped_prefix =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_GROUP_USE_PREFIX);
  $get_clauses =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_CLAUSES);
  $get_clause_name =
    Pha\create_member_accessor($script, Pha\MEMBER_NAMESPACE_USE_NAME);

  $no_prefix = '';
  $parse_clause_prefix = $clause ==> {
    $name = $get_clause_name($clause);
    if ($is_name($name)) {
      return $no_prefix;
    }

    return Pha\node_get_code_compressed($script, $name)
      |> Str\split($$, '\\')
      |> Vec\slice($$, 0, C\count($$) - 1)
      |> Str\join($$, '\\');
  };

  $parse_group_prefix = $use ==> $get_grouped_prefix($use)
    |> Pha\node_get_code_compressed($script, $$)
    |> Str\strip_suffix($$, '\\');

  $get_kind_as_enum = $use ==> $get_kind($use)
    |> $is_const($$)
      ? Support\UseKind::CONST
      : (
          $is_function($$)
            ? Support\UseKind::FUNCTION
            : (
                $is_namespace($$)
                  ? Support\UseKind::NAMESPACE
                  : (
                      $is_type($$)
                        ? Support\UseKind::TYPE
                        : Support\UseKind::NONE
                    )
              )
        );

  $use_clauses = Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_USE_DECLARATION,
  )
    |> Dict\group_by($$, $get_kind_as_enum)
    |> Dict\map(
      $$,
      $uses ==> Vec\map(
        $uses,
        $u ==> Pha\as_syntax($u)
          |> $get_clauses($$)
          |> Pha\as_syntax($$)
          |> Pha\list_get_items_of_children($script, $$),
      )
        |> Vec\flatten($$)
        |> Vec\map($$, Pha\as_syntax<>),
    );

  $grouped_uses = Pha\index_get_nodes_by_kind(
    $syntax_index,
    Pha\KIND_NAMESPACE_GROUP_USE_DECLARATION,
  )
    |> Dict\group_by($$, $get_kind_as_enum);

  // Just give up if the script contains any use clauses without a kind.
  if (
    C\contains_key($use_clauses, Support\UseKind::NONE) ||
    C\contains_key($grouped_uses, Support\UseKind::NONE)
  ) {
    return vec[];
  }

  return Vec\map(Support\REAL_USE_KINDS, $kind ==> {
    $prefixes = Vec\concat(
      idx($use_clauses, $kind, vec[])
        |> Vec\map($$, $x ==> tuple($x, $parse_clause_prefix($x))),
      idx($grouped_uses, $kind, vec[])
        |> Vec\map($$, $x ==> tuple($x, $parse_group_prefix($x))),
    );

    $seen_prefixes = keyset[];
    foreach ($prefixes as list($node, $prefix)) {
      if ($prefix === $no_prefix) {
        continue;
      }

      if (C\contains_key($seen_prefixes, $prefix)) {
        yield $node;
      }

      $seen_prefixes[] = $prefix;
    }
  })
    |> Vec\map($$, vec<>)
    |> Vec\flatten($$)
    |> Vec\map(
      $$,
      $n ==> new LintError(
        $script,
        $n,
        $linter,
        'This use directive can be grouped with a previous use directive.',
      ),
    );
}
