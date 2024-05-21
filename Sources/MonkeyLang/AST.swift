import Foundation

// MARK: - AST Entrypoint

struct Program: CustomStringConvertible, Equatable {
  var statements: [any Statement]
  
  var description: String {
    statements.map(\.description).joined(separator: "\n")
  }
  
  static func == (lhs: Program, rhs: Program) -> Bool {
    isEqual(lhs: lhs.statements, rhs: rhs.statements)
  }
}

// MARK: - AST Interface

protocol Node: Equatable, CustomStringConvertible {
  var token: Token { get }
}
protocol Statement: Node { }
protocol Expression: Node { }

// MARK: - AST Nodes

struct LetStatement: Statement {
  var token: Token
  var name: IdentifierExpression
  var value: any Expression
  
  var description: String {
    "\(token.literal) \(name.description) = \(value.description);"
  }
  
  static func == (lhs: LetStatement, rhs: LetStatement) -> Bool {
    lhs.token == rhs.token &&
    lhs.name == lhs.name &&
    isEqual(lhs: lhs.value, rhs: rhs.value)
  }
}

struct ReturnStatement: Statement {
  var token: Token
  var returnValue: any Expression
  
  var description: String {
    "\(token.literal) \(returnValue.description);"
  }
  
  static func == (lhs: ReturnStatement, rhs: ReturnStatement) -> Bool {
    lhs.token == rhs.token &&
    isEqual(lhs: lhs.returnValue, rhs: rhs.returnValue)
  }
}

struct BlockStatement: Statement {
  var token: Token
  var statements: [any Statement]
  
  var description: String {
    statements.map(\.description).joined()
  }
  
  static func == (lhs: BlockStatement, rhs: BlockStatement) -> Bool {
    lhs.token == rhs.token &&
    isEqual(lhs: lhs.statements, rhs: rhs.statements)
  }
}

struct ExpressionStatement: Statement {
  var token: Token
  var expression: any Expression
  
  var description: String {
    expression.description
  }
  
  static func == (lhs: ExpressionStatement, rhs: ExpressionStatement) -> Bool {
    lhs.token == rhs.token &&
    isEqual(lhs: lhs.expression, rhs: rhs.expression)
  }
}

struct EmptyExpression: Expression {
  var token: Token
  
  var description: String {
    ""
  }
}

struct IdentifierExpression: Expression {
  var token: Token
  var value: String
  
  var description: String {
    value
  }
}

struct IntegerExpression: Expression {
  var token: Token
  var value: Int
  
  var description: String {
    "\(value)"
  }
}

struct BooleanExpression: Expression {
  var token: Token
  var value: Bool
  
  var description: String {
    "\(value)"
  }
}

struct PrefixExpression: Expression {
  var token: Token
  var op: String
  var right: any Expression
  
  var description: String {
    "(\(op)\(right))"
  }
  
  static func == (lhs: PrefixExpression, rhs: PrefixExpression) -> Bool {
    lhs.token == rhs.token &&
    lhs.op == rhs.op &&
    isEqual(lhs: lhs.right, rhs: rhs.right)
  }
}

struct InfixExpression: Expression {
  var token: Token
  var op: String
  var left: any Expression
  var right: any Expression
  
  var description: String {
    "(\(left) \(op) \(right))"
  }
  
  static func == (lhs: InfixExpression, rhs: InfixExpression) -> Bool {
    lhs.token == rhs.token &&
    lhs.op == rhs.op &&
    isEqual(lhs: lhs.left, rhs: rhs.left) &&
    isEqual(lhs: lhs.right, rhs: rhs.right)
  }
}

struct IfExpression: Expression {
  var token: Token
  var condition: any Expression
  var consequence: BlockStatement
  var alternative: BlockStatement?
  
  var description: String {
    var desc = "\(token.literal) \(condition) \(consequence)"
    if let alternative {
      desc += " \(Token.else.literal) \(alternative)"
    }
    return desc
  }
  
  static func == (lhs: IfExpression, rhs: IfExpression) -> Bool {
    lhs.token == rhs.token &&
    isEqual(lhs: lhs.condition, rhs: rhs.condition) &&
    isEqual(lhs: lhs.consequence, rhs: rhs.consequence) &&
    isEqual(lhs: lhs.alternative, rhs: rhs.alternative)
  }
}

struct FunctionLiteral: Expression {
  var token: Token
  var parameters: [IdentifierExpression]
  var body: BlockStatement
  
  var description: String {
    let paramDesc = parameters.map(\.description).joined(separator: ", ")
    return "\(token.literal)(\(paramDesc)) \(body)"
  }
}

// MARK: - Open Existentials

private func isEqual(lhs: any Expression, rhs: any Expression) -> Bool {
  func _isEqual<A: Expression>(_ lhs: A, _ rhs: any Expression) -> Bool {
    guard let rhs = rhs as? A else { return false }
    return lhs == rhs
  }
  return _isEqual(lhs, rhs)
}

private func isEqual(lhs: (any Expression)?, rhs: (any Expression)?) -> Bool {
  if lhs == nil && rhs == nil {
    return true
  }
  guard let lhs, let rhs else {
    return false
  }
  return isEqual(lhs: lhs, rhs: rhs)
}

private func isEqual(lhs: [any Expression], rhs: [any Expression]) -> Bool {
  guard lhs.count == rhs.count else { return false }
  return zip(lhs, rhs).allSatisfy { isEqual(lhs: $0, rhs: $1) }
}

private func isEqual(lhs: any Statement, rhs: any Statement) -> Bool {
  func _isEqual<A: Statement>(_ lhs: A, _ rhs: any Statement) -> Bool {
    guard let rhs = rhs as? A else { return false }
    return lhs == rhs
  }
  return _isEqual(lhs, rhs)
}

private func isEqual(lhs: (any Statement)?, rhs: (any Statement)?) -> Bool {
  if lhs == nil && rhs == nil {
    return true
  }
  guard let lhs, let rhs else {
    return false
  }
  return isEqual(lhs: lhs, rhs: rhs)
}

private func isEqual(lhs: [any Statement], rhs: [any Statement]) -> Bool {
  guard lhs.count == rhs.count else { return false }
  return zip(lhs, rhs).allSatisfy { isEqual(lhs: $0, rhs: $1) }
}
