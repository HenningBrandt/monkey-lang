import Foundation
import CasePaths

final class Parser {
  private let lexer: Lexer
  private var curToken: Token
  private var peekToken: Token
  
  init(_ lexer: Lexer) {
    self.lexer = lexer
    self.curToken = lexer.nextToken()
    self.peekToken = lexer.nextToken()
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
      throw ParseError()
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
