import Foundation
import CasePaths

final class Parser {
  private let lexer: Lexer
  private var curToken: Token
  private var peekToken: Token
  private var semanticCode: SemanticCode
  
  init(_ lexer: Lexer) {
    self.lexer = lexer
    self.curToken = lexer.nextToken()
    self.peekToken = lexer.nextToken()
    self.semanticCode = SemanticCode()
    setupExpressionParsers()
  }
  
  struct ParseError: Error {}
  
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
    let name = Identifier(token: curToken, value: identName)
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
    peekToken = lexer.nextToken()
  }
  
  @discardableResult
  private func consumePeek<T>(_ tokenPath: CaseKeyPath<Token, T>) throws -> T {
    guard let res = peekToken[case: tokenPath] else {
      throw ParseError()
    }
    nextToken()
    return res
  }
}

// MARK: - Pratt Parser (Expressions)

enum OperatorPrecedence: Int {
  case lowest = 1
  case equals // ==
  case lessGreater // > or <
  case sum // +
  case product // *
  case prefix // -X or !X
  case call // myFunction(X)
}

extension Parser {
  private func setupExpressionParsers() {
    semanticCode.registerPrefix({ [unowned self] in self.parseIdentifier() }, forToken: .ident)
  }
  
  private func parseExpression(
    usingPrecedence precedence: OperatorPrecedence
  ) throws -> any Expression {
    guard let prefixParser = semanticCode[prefix: curToken.caseID] else {
      throw ParseError()
    }
    return try prefixParser()
  }
  
  private func parseIdentifier() -> Identifier {
    Identifier(token: curToken, value: curToken.literal)
  }
}

struct SemanticCode {
  typealias PrefixParser = () throws -> any Expression
  typealias InfixParser = (any Expression) throws -> any Expression
  
  private var prefixParsers: [Token.CaseID: PrefixParser] = [:]
  private var infixParsers: [Token.CaseID: InfixParser] = [:]
  
  mutating func registerPrefix(_ parser: @escaping PrefixParser, forToken tokenID: Token.CaseID) {
    prefixParsers[tokenID] = parser
  }
  
  mutating func registerInfix(_ parser: @escaping InfixParser, forToken tokenID: Token.CaseID) {
    infixParsers[tokenID] = parser
  }
  
  subscript(prefix tokenID: Token.CaseID) -> PrefixParser? {
    prefixParsers[tokenID]
  }

  subscript(infix tokenID: Token.CaseID) -> InfixParser? {
    infixParsers[tokenID]
  }
}

// MARK: - Convenience Methods

extension Parser {
  static func parse(_ input: String) throws -> Program {
    try Parser(Lexer(input)).parseProgram()
  }
}
