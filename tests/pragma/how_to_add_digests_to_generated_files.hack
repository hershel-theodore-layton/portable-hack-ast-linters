/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
use namespace HTL\{Pha, PhaLinters};
use type HTL\Pragma\Pragmas;

/**
 * This function demonstrates how you can add digests to generated sources.
 * This file adds a digest to itself when executed.
 * In your codegen logic, you would use the `$source` you just codegenned,
 * instead of contents of `__FILE__`.
 */
<<file: Pragmas(vec['PhaLinters', 'digest:'])>>

<<__EntryPoint>>
function how_to_add_digests_to_generated_files()[defaults]: void {
  $source = \file_get_contents(__FILE__);
  $ctx = Pha\create_context();
  list($script, $ctx) = Pha\parse($source as string, $ctx);
  $syntax_index = Pha\create_syntax_kind_index($script);
  $pragma_map = Pha\create_pragma_map($script, $syntax_index);
  $signed = PhaLinters\Support\insert_digest($script, $pragma_map);
  \file_put_contents(__FILE__, $signed);
}
