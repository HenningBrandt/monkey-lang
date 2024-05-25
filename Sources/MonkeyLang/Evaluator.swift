import Foundation

indirect enum Object: Equatable, CustomStringConvertible {
  case int(Int)
  case bool(Bool)
  case `return`(Object)
  case null
  
  var description: String {
    switch self {
    case let .int(int):
      "\(int)"
    case let .bool(bool):
      "\(bool)"
    case let .return(`return`):
      `return`.description
    case .null:
      "null"
    }
  }
  
  var isTruthy: Bool {
    switch self {
    case .int:
      true
    case let .bool(val):
      val
    case let .return(`return`):
      `return`.isTruthy
    case .null:
      false
    }
  }
}

struct Evaluator {
  func eval(_ node: any Node) -> Object {
    switch node {
    case let program as Program:
      evalProgram(program)
    case let statement as ExpressionStatement:
      eval(statement.expression)
    case let statement as BlockStatement:
      evalBlockStatement(statement)
    case let statement as ReturnStatement:
      .return(eval(statement.returnValue))
    case let exp as IntegerExpression:
      .int(exp.value)
    case let exp as BooleanExpression:
      .bool(exp.value)
    case let exp as PrefixExpression:
      evalPrefixExpression(op: exp.op, rhs: eval(exp.right))
    case let exp as InfixExpression:
      evalInfixExpression(op: exp.op, lhs: eval(exp.left), rhs: eval(exp.right))
    case let exp as IfExpression:
      evalIfExpression(exp)
    default:
      .null
    }
  }

  private func evalProgram(_ program: Program) -> Object {
    var res: Object = .null
    for statement in program.statements {
      res = eval(statement)
      if case let .return(returnValue) = res {
        return returnValue
      }
    }
    return res
  }
  
  private func evalBlockStatement(_ block: BlockStatement) -> Object {
    var res: Object = .null
    for statement in block.statements {
      res = eval(statement)
      if case .return = res {
        return res
      }
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
    case let .bool(bool):
      return .bool(!bool)
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
  
  private func evalIfExpression(_ exp: IfExpression) -> Object {
    if eval(exp.condition).isTruthy {
      eval(exp.consequence)
    } else if let alternative = exp.alternative {
      eval(alternative)
    } else {
      .null
    }
  }
}
