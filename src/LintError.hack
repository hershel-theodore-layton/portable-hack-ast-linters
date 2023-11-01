/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

use namespace HH\Lib\{C, Str};
use namespace HTL\Pha;

final class LintError {
  public string $statementText;

  public function __construct(
    private Pha\Script $script,
    private Pha\Node $blamedNode,
    private string $linterName,
    private string $description,
  )[] {
    // TODO: Delete ME!!!
    $this->statementText = Pha\node_get_syntax_ancestors($script, $blamedNode)
      |> C\find(
        $$,
        $n ==> Str\ends_with(Pha\node_get_kind($script, $n), '_statement'),
      )
      |> Pha\node_get_code($script, $$ ?? Pha\NIL);
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

  public function toString()[]: string {
    return Str\format(
      "Error(%s): %s\n-----\n%s\n-----\n%s\n----",
      $this->getLinterName(),
      $this->getDescription(),
      Pha\node_get_code($this->script, $this->getBlameNode()),
      $this->statementText,
    );
  }
}
