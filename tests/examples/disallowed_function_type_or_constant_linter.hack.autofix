//##! 0 Symbol declarations are not references
namespace Legacy {
  const int OLD_VALUE = 1;
  const bool OLD_FLAG = true;
  const int Shared = 1;

  function run(): void {}
  function Shared(): void {}

  class OldType {
    const int VALUE = 1;
    public function __construct(int $_ = 0) {}
    public static function method(): void {}
  }

  class Shared {}
  trait OldTrait {}
  class OldException extends \Exception {}
  class OldAttribute implements \HH\ClassAttribute {
    public function __construct(string $_) {}
  }
  xhp class old_element {
    public function __construct(
      dict<string, mixed> $_attributes,
      vec<mixed> $_children,
      string $_file,
      int $_line,
    ) {}
  }
}

namespace Other {
  class Type {
    const int OLD_VALUE = 1;
    public static function run(): void {}
  }
  class InstanceType {
    public function run(): void {}
  }
  class OldType {}
  const int OLD_VALUE = 1;
  function run(): void {}
  function consume(int $_): void {}
}

//##! 3 Fully qualified references and leading backslashes in configuration
namespace DisallowedFixture\FullyQualified {
  function example(): void {
    \Legacy\run();
    new \Legacy\OldType();
    $value = \Legacy\OLD_VALUE;
  }
}

//##! 6 Imported aliases and function pointers
namespace DisallowedFixture\ImportedAliases {
  use function Legacy\run as execute;
  use type Legacy\OldType as ImportedType;
  use const Legacy\OLD_VALUE as IMPORTED_VALUE;
  function example(ImportedType $value): ImportedType {
    execute();
    $callback = execute<>;
    new ImportedType(IMPORTED_VALUE);
    return $value;
  }
}

//##! 3 Namespace aliases
namespace DisallowedFixture\NamespaceAliases {
  use namespace Legacy as Old;
  function example(): void {
    Old\run();
    new Old\OldType();
    $value = Old\OLD_VALUE;
  }
}

//##! 3 References in the current namespace
namespace Legacy {
  function current_namespace_references(): void {
    run();
    new OldType();
    $value = OLD_VALUE;
  }
}

//##! 6 Type hints, generics, inheritance, and static access
namespace DisallowedFixture\TypeReferences {
  class Example extends \Legacy\OldType {
    public function example(?\Legacy\OldType $value): vec<\Legacy\OldType> {
      \Legacy\OldType::method();
      $constant = \Legacy\OldType::VALUE;
      $pointer = \Legacy\OldType::method<>;
      return vec[];
    }
  }
}

//##! 3 Overlapping names are classified by reference position
namespace DisallowedFixture\OverlappingNames {
  function example(): void {
    \Legacy\Shared();
    new \Legacy\Shared();
    $value = \Legacy\Shared;
  }
}

//##! 0 Imports, method names, and strings are not references
namespace DisallowedFixture\ExcludedReferences {
  use function Legacy\run;
  use type Legacy\OldType;
  use const Legacy\OLD_VALUE;
  function example(
    \Other\InstanceType $value,
    ?\Other\InstanceType $nullable,
  ): void {
    $value->run();
    $nullable?->run();
    \Other\Type::run();
    $constant = \Other\Type::OLD_VALUE;
    $callback = \Other\Type::run<>;
    $text = 'Legacy\\run';
  }
}

//##! 0 Unconfigured symbols
namespace Other {
  function unconfigured_references(Type $value): void {
    run();
    new OldType();
    $constant = OLD_VALUE;
  }
}

//##! 12 Constant reference positions
namespace DisallowedFixture\ConstantExpressions {
  function example(): mixed {
    $a = vec[\Legacy\OLD_VALUE];
    $b = keyset[\Legacy\OLD_VALUE];
    $c = dict[\Legacy\OLD_VALUE => \Legacy\OLD_VALUE];
    $d = shape('one' => \Legacy\OLD_VALUE, 'two' => \Legacy\OLD_VALUE);
    $e = (\Legacy\OLD_VALUE);
    $f = !\Legacy\OLD_FLAG;
    $g = \Legacy\OLD_FLAG ? \Legacy\OLD_VALUE : \Legacy\OLD_VALUE;
    return \Legacy\OLD_VALUE;
  }
}

//##! 2 Constants in argument lists and initializers
namespace DisallowedFixture\ConstantArguments {
  function example(int $value = \Legacy\OLD_VALUE): void {
    \Other\consume(\Legacy\OLD_VALUE);
  }
}

//##! 2 Enum values
namespace DisallowedFixture\EnumValues {
  use const Legacy\OLD_VALUE as IMPORTED_VALUE;
  enum E: int {
    VALUE = IMPORTED_VALUE;
  }
  enum class EC: int {
    int VALUE = \Legacy\OLD_VALUE;
  }
}

//##! 5 Attributes, class constants, traits, requirements, and catches
namespace DisallowedFixture\SpecialTypeReferences {
  use type Legacy\{
    OldAttribute as Attribute,
    OldException as ExceptionType,
    OldTrait as ImportedTrait,
    OldType as ParentType,
  };
  use const Legacy\OLD_VALUE as VALUE;
  <<Attribute('example')>>
  class Example {
    use ImportedTrait;
    const int C = VALUE;
    public function example(): void {
      try {
      } catch (ExceptionType $e) {
      }
    }
  }
  trait ExampleTrait {
    require extends ParentType;
  }
}

//##! 3 Imported builtin function and auto-imported type
namespace DisallowedFixture\Builtins {
  use function var_dump;
  function example(): void {
    var_dump('value');
    \var_dump('value');
    new Vector(vec[]);
  }
}

//##! 1 XHP opening names
namespace DisallowedFixture\Xhp {
  use namespace Legacy;
  function example(): void {
    $element = <Legacy:old_element></Legacy:old_element>;
  }
}
