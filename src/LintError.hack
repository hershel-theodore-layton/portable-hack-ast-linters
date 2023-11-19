/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str, Vec};
use namespace HTL\Pha;

final class LintError {
  private Pha\LineAndColumnNumbers $position;

  public function __construct(
    private Pha\Script $script,
    private Pha\Node $blamedNode,
    private string $linterName,
    private string $description,
  )[] {
    $this->position =
      Pha\node_get_line_and_column_numbers($script, $blamedNode);
  }

  public function getBlameNode()[]: Pha\Node {
    return $this->blamedNode;
  }

  public function getDescription()[]: string {
    return $this->description;
  }

  public function getLinterName()[]: string {
    return $this->linterName;
  }

  public function getLinterNameWithoutNamespaceAndLinter()[]: string {
    return Str\split($this->linterName, '\\')
      |> C\lastx($$)
      |> Str\strip_suffix($$, '_linter')
      |> Str\strip_suffix($$, 'Linter');
  }

  public function isIgnored(Pha\PragmaMap $pragma_map)[]: bool {
    return $pragma_map->getOverlappingPragmas($this->position)
      |> Vec\filter(
        $$,
        $p ==> Str\trim($p[0], '"\'')
          |> $$ === 'PhaLinters' || $$ === 'HTL\PhaLinters',
      )
      |> Vec\flatten($$)
      |> Vec\map($$, $str ==> Str\trim($str, '"\''))
      |> Vec\filter($$, $str ==> Str\starts_with($str, 'ignore:'))
      |> Vec\map($$, $str ==> Str\strip_prefix($str, 'ignore:'))
      |> C\contains($$, $this->getLinterNameWithoutNamespaceAndLinter());
  }

  public function toString()[]: string {
    return Str\format(
      "Error(%s): %s\n-----\n%s\n-----\nOn line: %d",
      $this->getLinterName(),
      $this->getDescription(),
      Pha\node_get_code($this->script, $this->getBlameNode()),
      Pha\node_get_line_and_column_numbers($this->script, $this->getBlameNode())
        ->getEndLine(),
    );
  }
}
