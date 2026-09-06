//##! 3 Arrow lambda in a method
class Foo {
  public function bar(): void {
    $_ = () ==> tuple(__FUNCTION__, __METHOD__, __FUNCTION_CREDENTIAL__);
  }
}

//##! 3 Block lambda in a function
function outer(): void {
  $_ = () ==> {
    $_ = __FUNCTION__;
    $_ = __METHOD__;
    $_ = __FUNCTION_CREDENTIAL__;
  };
}

//##! 3 Anonymous function
function anonymous(): void {
  $_ = function(): void {
    $_ = __FUNCTION__;
    $_ = __METHOD__;
    $_ = __FUNCTION_CREDENTIAL__;
  };
}

//##! 0 Constants outside closures and captured values
function captured(): void {
  $function = __FUNCTION__;
  $method = __METHOD__;
  $credential = __FUNCTION_CREDENTIAL__;
  $_ = () ==> tuple($function, $method, $credential);
}
class Outside {
  public function bar(): void {
    $_ = tuple(__FUNCTION__, __METHOD__, __FUNCTION_CREDENTIAL__);
  }
}

//##! 3 Nested lambdas
function nested(): void {
  $_ = () ==> () ==> tuple(__FUNCTION__, __METHOD__, __FUNCTION_CREDENTIAL__);
}

//##! 2 Async closures
function async_closures(): void {
  $_ = async () ==> __FUNCTION__;
  $_ = async function(): Awaitable<void> {
    $_ = __FUNCTION_CREDENTIAL__;
  };
}

//##! 0 Other constants, strings, and comments
trait OtherConstants {
  public function otherConstants(): void {
    $_ = () ==> {
      $_ =
        tuple(__CLASS__, __TRAIT__, __NAMESPACE__, __FILE__, __DIR__, __LINE__);
      $_ = '__FUNCTION__ __METHOD__ __FUNCTION_CREDENTIAL__';
      // __FUNCTION__ __METHOD__ __FUNCTION_CREDENTIAL__
    };
  }
}

//##! 1 A credential used as the receiver is still a magic constant
function credential_receiver(): void {
  $_ = () ==> __FUNCTION_CREDENTIAL__->getFunctionName();
}

//##! 0 Member names are not magic constants
function member_names(dynamic $object): void {
  $_ = () ==> {
    $_ = $object->__METHOD__;
    $_ = $object?->__FUNCTION__;
  };
}

//##! 0 Magic constants without any enclosing function or lambda
const string METHOD_CONSTANT_GLOBAL_FUNCTION = __FUNCTION__;
const string METHOD_CONSTANT_GLOBAL_METHOD = __METHOD__;

final class MethodConstantOutsideCallable {
  const string FUNCTION_NAME = __FUNCTION__;
  const string METHOD_NAME = __METHOD__;
  public string $functionName = __FUNCTION__;
  public string $methodName = __METHOD__;
}

//##! 3 Lambda in a parameter default
function lambda_parameter_default(
  mixed $callback = () ==>
    tuple(__FUNCTION__, __METHOD__, __FUNCTION_CREDENTIAL__),
): void {}

//##! 3 Async blocks create implicit lambdas
function async_block(): void {
  $_ = async {
    return tuple(__FUNCTION__, __METHOD__, __FUNCTION_CREDENTIAL__);
  };
}
