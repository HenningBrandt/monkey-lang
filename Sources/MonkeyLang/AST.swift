import Foundation

// MARK: - AST Entrypoint

struct Program: CustomStringConvertible {
  var statements: [any Statement]
  
  var description: String {
    statements.map(\.description).joined(separator: "\n")
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

// MARK: - Open Existentials

private func isEqual<A: Expression>(lhs: A, rhs: any Expression) -> Bool {
  guard let rhs = rhs as? A else { return false }
  return lhs == rhs
}
