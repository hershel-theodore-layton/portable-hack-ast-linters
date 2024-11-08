//##! 0 Open shapes
namespace Linters\Tests\ShapeTypeAdditionalFieldIntentShouldBeExplicit;

type A = shape(...);
type B = shape('b' => int, ...);
type C = shape(?'c' => int, ...);
type D = shape(
  'multiline' => int,
  'shape' => int,
  'with' => int,
  'many' => int,
  'keys' => int,
  ...
);

//##! 0 Using the configured `/*_*/` pseudo syntax

type E = shape(/*_*/);
type F = shape('f' => int /*_*/);
type G = shape(?'g' => int /*_*/);
type H = shape(
  'multiline' => int,
  'shape' => int,
  'with' => int,
  'many' => int,
  'keys' => int,
  /*_*/
);

//##! 4 implicitly closed

type I = shape();
type J = shape('j' => int);
type K = shape(?'k' => int);
type L = shape(
  'multiline' => int,
  'shape' => int,
  'with' => int,
  'many' => int,
  'keys' => int,
);

//##! 2 incorrect pseudo syntax use
type M = shape(/*_*/ 'm' => int);
type N = shape('n' => int /*@@*/);
