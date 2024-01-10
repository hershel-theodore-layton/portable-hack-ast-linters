/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

final class LintError {
  public function __construct(
    private string $linterName,
    private string $description,
    private Pha\Node $blamedNode,
    private Pha\LineAndColumnNumbers $position,
    private string $code,
    private bool $isIgnored,
  )[] {}

  public static function create(
    Pha\Script $script,
    Pha\PragmaMap $pragma_map,
    Pha\Node $blamed_node,
    string $linter_name,
    string $description,
  )[]: this {
    $position = Pha\node_get_line_and_column_numbers($script, $blamed_node);
    return new static(
      $linter_name,
      $description,
      $blamed_node,
      $position,
      Pha\node_get_code($script, $blamed_node),
      static::isIgnoredImpl($pragma_map, $position, $linter_name),
    );
  }

  public function getBlamedNode()[]: Pha\Node {
    return $this->blamedNode;
  }

  public function getDescription()[]: string {
    return $this->description;
  }

  public function getLinterName()[]: string {
    return $this->linterName;
  }

  public function getLinterNameWithoutNamespaceAndLinter()[]: string {
    return static::stripLinterSuffix($this->linterName);
  }

  public function getPosition()[]: Pha\LineAndColumnNumbers {
    return $this->position;
  }

  public function isIgnored()[]: bool {
    return $this->isIgnored;
  }

  public function toString()[]: string {
    return Str\format(
      "Error(%s): %s\n-----\n%s\n-----\nOn line: %d",
      $this->getLinterName(),
      $this->getDescription(),
      $this->code,
      $this->position->getEndLine(),
    );
  }

  private static function isIgnoredImpl(
    Pha\PragmaMap $pragma_map,
    Pha\LineAndColumnNumbers $position,
    string $linter_name,
  )[]: bool {
    return $pragma_map->getOverlappingPragmas($position)
      |> Vec\filter(
        $$,
        $p ==> Str\trim($p[0], '"\'')
          |> $$ === 'PhaLinters' || $$ === 'HTL\PhaLinters',
      )
      |> Vec\flatten($$)
      |> Vec\map($$, $str ==> Str\trim($str, '"\''))
      |> Vec\filter($$, $str ==> Str\starts_with($str, 'fixme:'))
      |> Vec\map($$, $str ==> Str\strip_prefix($str, 'fixme:'))
      |> C\contains($$, static::stripLinterSuffix($linter_name));
  }

  private static function stripLinterSuffix(string $linter_name)[]: string {
    return Str\split($linter_name, '\\')
      |> C\lastx($$)
      |> Str\strip_suffix($$, '_linter')
      |> Str\strip_suffix($$, 'Linter');
  }
}
