import Foundation
import CasePaths

final class Parser {
  private let tokens: Lexer.Iterator
  private var curToken: Token
  private var peekToken: Token
  private var semanticCode: SemanticCode
  
  init(_ lexer: Lexer) {
    self.tokens = lexer.makeIterator()
    self.curToken = tokens.next() ?? .eof
    self.peekToken = tokens.next() ?? .eof
    self.semanticCode = SemanticCode()
    setupExpressionParsers()
  }
  
  enum ParseError: Error {
    case generic
    case typeError(String)
    case prefixParserNotFound(String)
  }
  
  // TODO: Parser is throwing, so it fails on the first error. Don't throw and collect errors instead.
  func parseProgram() throws -> Program {
    var statements: [any Statement] = []
    
    while curToken != .eof {
      let statement = try parseStatement()
      statements.append(statement)
      nextToken()
    }
    
    return Program(statements: statements)
  }
  
  // MARK: Parse Nodes
  
  private func parseStatement() throws -> any Statement {
    switch curToken {
    case .let:
      try parseLetStatement()
    case .return:
      try parseReturnStatement()
    default:
      try parseExpressionStatement()
    }
  }
  
  private func parseLetStatement() throws -> LetStatement {
    let token = curToken
    let identName = try consumePeek(\.ident)
    let name = IdentifierExpression(token: curToken, value: identName)
    try consumePeek(\.assign)
    
    // TODO: Implement expression parsing. Skip to semicolon for now.
    while curToken != .semicolon {
      nextToken()
    }
    
    return LetStatement(token: token, name: name, value: EmptyExpression(token: token))
  }
  
  private func parseReturnStatement() throws -> ReturnStatement {
    let token = curToken

    // TODO: Implement expression parsing. Skip to semicolon for now.
    while curToken != .semicolon {
      nextToken()
    }
    
    return ReturnStatement(token: token, returnValue: EmptyExpression(token: token))
  }
  
  private func parseExpressionStatement() throws -> ExpressionStatement {
    let token = curToken
    let expression = try parseExpression(usingPrecedence: .lowest)
    
    if peekToken == .semicolon {
      nextToken()
    }
    
    return ExpressionStatement(token: token, expression: expression)
  }
  
  // MARK: Token Helper
  
  private func nextToken() {
    curToken = peekToken
    peekToken = tokens.next() ?? .eof
  }
  
  @discardableResult
  private func consumePeek<T>(_ tokenPath: CaseKeyPath<Token, T>) throws -> T {
    guard let res = peekToken[case: tokenPath] else {
      throw ParseError.generic
    }
    nextToken()
    return res
  }
}

// MARK: - Pratt Parser (Expressions)

enum OperatorPrecedence: Int, Comparable {
  case lowest = 1
  case equals // ==
  case lessGreater // > or <
  case sum // +
  case product // *
  case prefix // -X or !X
  case call // myFunction(X)
  
  static func < (lhs: OperatorPrecedence, rhs: OperatorPrecedence) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

private let precedences: [Token: OperatorPrecedence] = [
  .eq: .equals,
  .notEq: .equals,
  .lt: .lessGreater,
  .gt: .lessGreater,
  .plus: .sum,
  .minus: .sum,
  .slash: .product,
  .asterisk: .product,
]

extension Parser {
  private func setupExpressionParsers() {
    semanticCode[prefix: .ident] = { [unowned self] in self.parseIdentifier() }
    semanticCode[prefix: .int] = { [unowned self] in try self.parseInteger() }
    semanticCode[prefix: .lparen] = { [unowned self] in try self.parseGroupExpression() }
    [.bang, .minus].forEach {
      semanticCode[prefix: $0] = { [unowned self] in try self.parsePrefixExpression() }
    }
    [.true, .false].forEach {
      semanticCode[prefix: $0] = { [unowned self] in try self.parseBooleanExpression() }
    }
    [.plus, .minus, .slash, .asterisk, .eq, .notEq, .lt, .gt].forEach {
      semanticCode[infix: $0] = { [unowned self] in try self.parseInfixExpression(lhs: $0) }
    }
  }

  private func parseExpression(
    usingPrecedence precedence: OperatorPrecedence
  ) throws -> any Expression {
    guard let prefixParser = semanticCode[prefix: curToken.caseID] else {
      throw ParseError.prefixParserNotFound("no prefix parse function for \(curToken.literal)")
    }

    var expression = try prefixParser()
    
    while peekToken != .semicolon && precedence < peekPrecedence {
      guard let infixParser = semanticCode[infix: peekToken.caseID] else {
        return expression
      }
      nextToken()
      expression = try infixParser(expression)
    }
    
    return expression
  }
  
  private func parseGroupExpression() throws -> any Expression {
    nextToken()
    let expression = try parseExpression(usingPrecedence: .lowest)
    try consumePeek(\.rparen)
    return expression
  }

  private func parseIdentifier() -> IdentifierExpression {
    IdentifierExpression(token: curToken, value: curToken.literal)
  }
  
  private func parseInteger() throws -> IntegerExpression {
    // TODO: Just use value from token
    guard let value = Int(curToken.literal) else {
      throw ParseError.typeError("Expect integer got \(curToken.literal)")
    }
    return IntegerExpression(token: curToken, value: value)
  }
  
  private func parseBooleanExpression() throws -> BooleanExpression {
    guard let value = Bool(curToken.literal) else {
      throw ParseError.typeError("Expect boolean got \(curToken.literal)")
    }
    return BooleanExpression(token: curToken, value: value)
  }
  
  private func parsePrefixExpression() throws -> PrefixExpression {
    let token = curToken
    nextToken()
    return try PrefixExpression(
      token: token,
      op: token.literal,
      right: parseExpression(usingPrecedence: .prefix)
    )
  }
  
  private func parseInfixExpression(lhs: any Expression) throws -> InfixExpression {
    let precedence = curPrecedence
    let token = curToken
    nextToken()
    return try InfixExpression(
      token: token,
      op: token.literal,
      left: lhs,
      right: parseExpression(usingPrecedence: precedence)
    )
  }

  private var peekPrecedence: OperatorPrecedence {
    precedences[peekToken] ?? .lowest
  }

  private var curPrecedence: OperatorPrecedence {
    precedences[curToken] ?? .lowest
  }
}

struct SemanticCode {
  typealias PrefixParser = () throws -> any Expression
  typealias InfixParser = (any Expression) throws -> any Expression
  
  private var prefixParsers: [Token.CaseID: PrefixParser] = [:]
  private var infixParsers: [Token.CaseID: InfixParser] = [:]

  subscript(prefix tokenID: Token.CaseID) -> PrefixParser? {
    get {
      prefixParsers[tokenID]
    }
    set(newValue) {
      prefixParsers[tokenID] = newValue
    }
  }

  subscript(infix tokenID: Token.CaseID) -> InfixParser? {
    get {
      infixParsers[tokenID]
    }
    set(newValue) {
      infixParsers[tokenID] = newValue
    }
  }
}

// MARK: - Convenience Methods

extension Parser {
  static func parse(_ input: String) throws -> Program {
    try Parser(Lexer(input)).parseProgram()
  }
}
