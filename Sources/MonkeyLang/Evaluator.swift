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
      let rhs = eval(node: exp.right)
      return evalPrefixExpression(op: exp.op, rhs: rhs)
    case let exp as InfixExpression:
      let lhs = eval(node: exp.left)
      let rhs = eval(node: exp.right)
      return evalInfixExpression(op: exp.op, lhs: lhs, rhs: rhs)
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
  
  private func evalInfixExpression(op: String, lhs: Object, rhs: Object) -> Object {
    if case let .int(lVal) = lhs, case let .int(rVal) = rhs {
      return evalIntegerInfixExpression(op: op, lhs: lVal, rhs: rVal)
    }
    if case let .bool(lVal) = lhs, case let .bool(rVal) = rhs {
      return evalBooleanInfixExpression(op: op, lhs: lVal, rhs: rVal)
    }
    return .null
  }
  
  private func evalIntegerInfixExpression(op: String, lhs: Int, rhs: Int) -> Object {
    switch op {
    case "+":
      .int(lhs + rhs)
    case "-":
      .int(lhs - rhs)
    case "*":
      .int(lhs * rhs)
    case "/":
      .int(lhs / rhs)
    case "<":
      .bool(lhs < rhs)
    case ">":
      .bool(lhs > rhs)
    case "==":
      .bool(lhs == rhs)
    case "!=":
      .bool(lhs != rhs)
    default:
      .null
    }
  }
  
  private func evalBooleanInfixExpression(op: String, lhs: Bool, rhs: Bool) -> Object {
    switch op {
    case "==":
      .bool(lhs == rhs)
    case "!=":
      .bool(lhs != rhs)
    default:
      .null
    }
  }
}
