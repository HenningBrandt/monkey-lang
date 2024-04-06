import Foundation

// MARK: - AST Entrypoint

struct Program {
  var statements: [any Statement]
}

// MARK: - AST Interface

protocol Node: Equatable {
  var token: Token { get }
}
protocol Statement: Node { }
protocol Expression: Node { }

// MARK: - AST Nodes

struct LetStatement: Statement {
  var token: Token
  var name: Identifier
  var value: any Expression
  
  static func == (lhs: LetStatement, rhs: LetStatement) -> Bool {
    lhs.token == rhs.token &&
    lhs.name == lhs.name &&
    isEqual(lhs: lhs.value, rhs: rhs.value)
  }
}

struct Identifier: Expression {
  var token: Token
  var value: String
}

struct ReturnStatement: Statement {
  var token: Token
  var returnValue: any Expression
  
  static func == (lhs: ReturnStatement, rhs: ReturnStatement) -> Bool {
    lhs.token == rhs.token &&
    isEqual(lhs: lhs.returnValue, rhs: rhs.returnValue)
  }
}

struct EmptyExpression: Expression {
  var token: Token
}

// MARK: - Open Existentials

private func isEqual<A: Expression>(lhs: A, rhs: any Expression) -> Bool {
  guard let rhs = rhs as? A else { return false }
  return lhs == rhs
}
