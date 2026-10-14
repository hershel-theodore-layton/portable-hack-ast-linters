/** portable-hack-ast-linters is MIT licensed, see /LICENSE. */
namespace HTL\PhaLinters;

type TDisallowedEntities = shape(
  ?'functions' => dict<string, string>,
  ?'types' => dict<string, string>,
  ?'constants' => dict<string, string>,
  /*_*/
);
