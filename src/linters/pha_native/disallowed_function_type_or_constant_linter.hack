/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Dict, Str, Vec};
use namespace HTL\Pha;

/** Reports references to configured symbols with the supplied advice. */
function disallowed_function_type_or_constant_linter(
  shape(
    ?'functions' => dict<string, string>,
    ?'types' => dict<string, string>,
    ?'constants' => dict<string, string>,
    /*_*/
  ) $configuration,
)[]: (function(
  Pha\Script,
  Pha\SyntaxIndex,
  Pha\TokenIndex,
  Pha\Resolver,
  Pha\PragmaMap,
)[]: vec<LintError>) {
  $linter = __FUNCTION__;
  $symbols = dict[
    'functions' => Shapes::idx($configuration, 'functions', dict[]),
    'types' => Shapes::idx($configuration, 'types', dict[]),
    'constants' => Shapes::idx($configuration, 'constants', dict[]),
  ]
    |> Dict\map(
      $$,
      $names ==> Dict\map_keys($names, $n ==> Str\strip_prefix($n, '\\')),
    );

  // Only reference positions are examined: declarations, imports, and member
  // names do not refer to a free function, type, or global constant.
  $members = dict[
    'functions' => vec[
      Pha\MEMBER_FUNCTION_CALL_RECEIVER,
      Pha\MEMBER_FUNCTION_POINTER_RECEIVER,
    ],
    'types' => vec[
      Pha\MEMBER_SIMPLE_TYPE_SPECIFIER,
      Pha\MEMBER_GENERIC_CLASS_TYPE,
      Pha\MEMBER_CONSTRUCTOR_CALL_TYPE,
      Pha\MEMBER_SCOPE_RESOLUTION_QUALIFIER,
      Pha\MEMBER_COLLECTION_LITERAL_NAME,
      Pha\MEMBER_NAMEOF_TARGET,
      Pha\MEMBER_XHP_OPEN_NAME,
    ],
    'constants' => vec[
      Pha\MEMBER_BINARY_LEFT_OPERAND,
      Pha\MEMBER_BINARY_RIGHT_OPERAND,
      Pha\MEMBER_PREFIX_UNARY_OPERAND,
      Pha\MEMBER_POSTFIX_UNARY_OPERAND,
      Pha\MEMBER_CONDITIONAL_TEST,
      Pha\MEMBER_CONDITIONAL_CONSEQUENCE,
      Pha\MEMBER_CONDITIONAL_ALTERNATIVE,
      Pha\MEMBER_PARENTHESIZED_EXPRESSION_EXPRESSION,
      Pha\MEMBER_BRACED_EXPRESSION_EXPRESSION,
      Pha\MEMBER_DECORATED_EXPRESSION_EXPRESSION,
      Pha\MEMBER_EXPRESSION_STATEMENT_EXPRESSION,
      Pha\MEMBER_RETURN_EXPRESSION,
      Pha\MEMBER_THROW_EXPRESSION,
      Pha\MEMBER_YIELD_OPERAND,
      Pha\MEMBER_SIMPLE_INITIALIZER_VALUE,
      Pha\MEMBER_ENUMERATOR_VALUE,
      Pha\MEMBER_CAST_OPERAND,
      Pha\MEMBER_FUNCTION_CALL_ARGUMENT_LIST,
      Pha\MEMBER_CONSTRUCTOR_CALL_ARGUMENT_LIST,
      Pha\MEMBER_ELEMENT_KEY,
      Pha\MEMBER_ELEMENT_VALUE,
      Pha\MEMBER_FIELD_INITIALIZER_NAME,
      Pha\MEMBER_FIELD_INITIALIZER_VALUE,
      Pha\MEMBER_FIELD_NAME,
      Pha\MEMBER_SUBSCRIPT_RECEIVER,
      Pha\MEMBER_SUBSCRIPT_INDEX,
      Pha\MEMBER_MEMBER_OBJECT,
      Pha\MEMBER_SAFE_MEMBER_OBJECT,
      Pha\MEMBER_AS_LEFT_OPERAND,
      Pha\MEMBER_IS_LEFT_OPERAND,
      Pha\MEMBER_NULLABLE_AS_LEFT_OPERAND,
      Pha\MEMBER_IF_CONDITION,
      Pha\MEMBER_ELSEIF_CONDITION,
      Pha\MEMBER_WHILE_CONDITION,
      Pha\MEMBER_DO_CONDITION,
      Pha\MEMBER_FOR_INITIALIZER,
      Pha\MEMBER_FOR_CONTROL,
      Pha\MEMBER_FOR_END_OF_LOOP,
      Pha\MEMBER_FOREACH_COLLECTION,
      Pha\MEMBER_SWITCH_EXPRESSION,
      Pha\MEMBER_CASE_EXPRESSION,
      Pha\MEMBER_LAMBDA_BODY,
      Pha\MEMBER_TUPLE_EXPRESSION_ITEMS,
      Pha\MEMBER_VECTOR_INTRINSIC_MEMBERS,
      Pha\MEMBER_KEYSET_INTRINSIC_MEMBERS,
      Pha\MEMBER_COLLECTION_LITERAL_INITIALIZERS,
      Pha\MEMBER_ECHO_EXPRESSIONS,
    ],
  ];

  return ($script, $syntax_index, $_, $resolver, $pragma_map)[] ==> {
    $is_name = Pha\create_matcher(
      $script,
      vec[Pha\KIND_QUALIFIED_NAME],
      vec[
        Pha\KIND_NAME,
        Pha\KIND_XHP_CLASS_NAME,
        Pha\KIND_XHP_ELEMENT_NAME,
      ],
      vec[],
    );
    $is_list = Pha\create_syntax_matcher($script, Pha\KIND_NODE_LIST);
    $errors = vec[];
    foreach ($members as $kind => $reference_members) {
      if (C\is_empty($symbols[$kind])) {
        continue;
      }
      foreach ($reference_members as $member) {
        $get_reference = Pha\create_member_accessor($script, $member);
        $nodes = Pha\index_get_nodes_by_kind(
          $syntax_index,
          Pha\member_get_syntax_kind($member),
        );
        foreach ($nodes as $node) {
          $reference = $get_reference($node);
          $names = $is_list($reference)
            ? Pha\list_get_items_of_children($script, Pha\as_syntax($reference))
            : vec[$reference];
          foreach ($names as $name) {
            if (!$is_name($name)) {
              continue;
            }
            $advice =
              idx($symbols[$kind], Pha\resolve_name($resolver, $script, $name));
            if ($advice is null) {
              continue;
            }
            $errors[] = LintError::createWithoutPatches(
              $script,
              $pragma_map,
              $name,
              $linter,
              $advice,
            );
          }
        }
      }
    }
    return Vec\sort_by(
      $errors,
      $e ==> Pha\node_get_source_order($e->getBlamedNode()),
    );
  };
}
