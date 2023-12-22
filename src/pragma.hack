/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\Pragma;

/**
 * @package The `pragma(...)` directive and `<<Pragmas(...)>>`
 * attribute are a more structured way to communicate with source analyzers.
 * The typechecker looks for hh_fixme and hh_ignore_error directives.
 * HHAST looks for hhast_ignore_error, hhast_ignore_all, and hhast_fixme directives.
 *
 * I don't like the state of things, because nothings checks the comments.
 * It is unclear if a comment is a directive for something, a normal comment,
 * or a mistyped directive that is dangling.
 *
 * I am not going to change the typechecker,
 * but userspace libraries are welcome to adopt this informal standard.
 * There are two ways to invoke a pragma.
 *  - The `pragma('example_lib', 'strict_mode=1')` directive.
 *  - The `<<Pragmas(vec['one', 'ok=1'], vec['two', 'ok=false'])>>` attribute.
 *
 * The pragma directive accepts any number of arguments.
 * The 1st addresses a library, and the 2nd to last are implementation defined.
 * These take effect for the lines they are on and the next line.
 *
 * The attribute takes any number of vecs, each of which is a directive.
 * The scope is from attribute to closing curly brace if atop a class.
 * A file attribute `<<file: Pragmas(...)>>` affects the entire file.
 *
 * A library that uses pragma's is required to emit a diagnostic for pragmas
 * that start with the library name and that can not be parsed or are invalid.
 * This prevents a `pragma(...)` directive from being invalid.
 *
 * You must use a canonical use statement for the pragma directive and attribute.
 * Using a Pragma namespace and using qualfied names is not allowed.
 * `use namespace HTL\Pragma; ... Pragma\pragma(...) ... <<Pragma\Pragmas(...)>>`
 * Using `use function HTL\Pragma\pragma as not_pragma` is also not allowed.
 *
 * A PragmaMap scanner is included in `hershel-theodore-layton/portable-hack-ast`.
 * A checker for aimless pragmas (where the library is not known) is included in
 * `hershel-theodore-layton/portable-hack-ast-linters`.
 */
use namespace HH;

/**
 * @package This code will move to its own package.
 */

/**
 * @param ...$_args[0] The name of the library you are targetting.
 * @param ...$_args[1..] Arguments passed to the library.
 */
function pragma(string ...$_args)[]: void {}

/**
 * Apply a set of pragmas to an entire scope.
 * Each `vec[]` is parsed as its own `pragma(...)` directive.
 */
final class Pragmas
  implements
    HH\ClassAttribute,
    HH\EnumAttribute,
    /* HHVM 4.103+ exclusive HH\EnumClassAttribute, */
    HH\FunctionAttribute,
    HH\MethodAttribute,
    HH\FileAttribute {
  public vec<vec<string>> $values;

  public function __construct(vec<string> ...$values)[] {
    $this->values = vec($values);
  }
}
