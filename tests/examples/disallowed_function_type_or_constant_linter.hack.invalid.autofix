//##! 3 Fully qualified references and leading backslashes in configuration
function example(): void {
  \Legacy\run();
  new \Legacy\OldType();
  $value = \Legacy\OLD_VALUE;
}

//##! 6 Imported aliases and function pointers
namespace Client;
use function Legacy\run as execute;
use type Legacy\OldType as ImportedType;
use const Legacy\OLD_VALUE as IMPORTED_VALUE;
function example(ImportedType $value): ImportedType {
  execute();
  $callback = execute<>;
  new ImportedType(IMPORTED_VALUE);
  return $value;
}

//##! 3 Namespace aliases
namespace Client;
use namespace Legacy as Old;
function example(): void {
  Old\run();
  new Old\OldType();
  $value = Old\OLD_VALUE;
}

//##! 3 References in the current namespace
namespace Legacy;
function example(): void {
  run();
  new OldType();
  $value = OLD_VALUE;
}

//##! 6 Type hints, generics, inheritance, and static access
class Example extends \Legacy\OldType {
  public function example(
    ?\Legacy\OldType $value,
  ): vec<\Legacy\OldType> {
    \Legacy\OldType::method();
    $constant = \Legacy\OldType::VALUE;
    $pointer = \Legacy\OldType::method<>;
    return vec[];
  }
}

//##! 3 Overlapping names are classified by reference position
function example(): void {
  \Legacy\Shared();
  new \Legacy\Shared();
  $value = \Legacy\Shared;
}

//##! 0 Imports, declarations, method names, and strings are not references
namespace Legacy;
use function Legacy\run;
use type Legacy\OldType;
use const Legacy\OLD_VALUE;
const int OLD_VALUE = 1;
class OldType {
  const int OLD_VALUE = 1;
  public static function run(): void {}
}
function run(): void {}
function example(\Other\Type $value): void {
  $value->run();
  $value?->run();
  \Other\Type::run();
  $value = \Other\Type::OLD_VALUE;
  $callback = \Other\Type::run<>;
  $text = 'Legacy\\run';
}

//##! 0 Unconfigured symbols
namespace Other;
function example(Type $value): void {
  run();
  new OldType();
  $value = OLD_VALUE;
}

//##! 12 Constant reference positions
function example(): mixed {
  $a = vec[\Legacy\OLD_VALUE];
  $b = keyset[\Legacy\OLD_VALUE];
  $c = dict[\Legacy\OLD_VALUE => \Legacy\OLD_VALUE];
  $d = shape(\Legacy\OLD_VALUE => \Legacy\OLD_VALUE);
  $e = (\Legacy\OLD_VALUE);
  $f = !\Legacy\OLD_VALUE;
  $g = \Legacy\OLD_VALUE ? \Legacy\OLD_VALUE : \Legacy\OLD_VALUE;
  return \Legacy\OLD_VALUE;
}

//##! 2 Constants in argument lists and initializers
function example(mixed $value = \Legacy\OLD_VALUE): void {
  other(\Legacy\OLD_VALUE);
}

//##! 2 Enum values
namespace Client;
use const Legacy\OLD_VALUE as IMPORTED_VALUE;
enum E: int {
  VALUE = IMPORTED_VALUE;
}
enum class EC: int {
  int VALUE = \Legacy\OLD_VALUE;
}

//##! 6 Attributes, class constants, traits, requirements, and catches
namespace Client;
use type Legacy\OldType as Old;
use const Legacy\OLD_VALUE as VALUE;
<<Old(VALUE)>>
class Example {
  use Old;
  const int C = VALUE;
  public function example(): void {
    try {} catch (Old $e) {}
  }
}
trait ExampleTrait {
  require extends Old;
}

//##! 3 Imported builtin function and auto-imported type
namespace Client;
use function var_dump;
function example(): void {
  var_dump('value');
  \var_dump('value');
  new Vector();
}

//##! 1 XHP opening names
function example(): void {
  $element = <Legacy:old_element></Legacy:old_element>;
}
