import Foundation

enum Object: Equatable, CustomStringConvertible {
  case int(Int)
  case bool(Bool)
  case null
  
  var description: String {
    switch self {
    case .int(let int):
      "\(int)"
    case .bool(let bool):
      "\(bool)"
    case .null:
      "null"
    }
  }
}

// TODO: Might be better off as a class?
struct Evaluator {
  func eval(node: any Node) -> Object {
    switch node {
    case let program as Program:
      return evalStatements(program.statements)
    case let statement as ExpressionStatement:
      return eval(node: statement.expression)
    case let exp as IntegerExpression:
      return .int(exp.value)
    case let exp as BooleanExpression:
      return .bool(exp.value)
    case let exp as PrefixExpression:
      let right = eval(node: exp.right)
      return evalPrefixExpression(op: exp.op, rhs: right)
    default:
      return .null
    }
  }

  private func evalStatements(_ statements: [any Statement]) -> Object {
    var res: Object = .null
    for statement in statements {
      res = eval(node: statement)
    }
    return res
  }
  
  private func evalPrefixExpression(op: String, rhs: Object) -> Object {
    switch op {
    case "!":
      return evalBangOperatorExpression(rhs: rhs)
    case "-":
      return evalMinusPrefixOperatorExpression(rhs: rhs)
    default:
      return .null
    }
  }
  
  private func evalBangOperatorExpression(rhs: Object) -> Object {
    switch rhs {
    case .bool(let val):
      return .bool(!val)
    case .null:
      return .bool(true)
    default:
      return .bool(false)
    }
  }
  
  private func evalMinusPrefixOperatorExpression(rhs: Object) -> Object {
    guard case let .int(n) = rhs else {
      return .null
    }
    return .int(-n)
  }
}
