import Foundation
import Nimble
@testable import MonkeyLang

// MARK: - Statement Matchers

typealias StatementMatcher = Matcher<any MonkeyLang.Statement>

extension StatementMatcher {
  static func `let`(_ name: String) -> StatementMatcher {
    Matcher { input in
      guard let statement = try input.evaluate() as? LetStatement else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a let statement")
        )
      }
      guard statement.token.literal == "let" else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("have 'let' token")
        )
      }
  
      let result = statement.name.value == name && statement.name.token.literal == name
      return MatcherResult(
        bool: result,
        message: .expectedCustomValueTo("be named \(name)", actual: statement.name.value)
      )
    }
  }
  
  static func `return`() -> StatementMatcher {
    Matcher { input in
      guard let statement = try input.evaluate() as? ReturnStatement else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a return statement")
        )
      }
      
      let result = statement.token.literal == "return"
      return MatcherResult(
        bool: result,
        message: .expectedCustomValueTo("have 'return' token", actual: statement.token.literal)
      )
    }
  }
  
  static func expression(_ matcher: ExpressionMatcher) -> StatementMatcher {
    Matcher { input in
      guard let statement = try input.evaluate() as? ExpressionStatement else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be an expression statement")
        )
        
      }
      
      return try matcher.satisfies(
        Expression(
          expression: { statement.expression },
          location: input.location
        )
      )
    }
  }
}

// MARK: - Expression Matchers

typealias ExpressionMatcher = Matcher<any MonkeyLang.Expression>

extension ExpressionMatcher {
  static func prefix(
    _ op: String,
    _ rhs: ExpressionMatcher
  ) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? PrefixExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a prefix expression")
        )
      }
      
      guard exp.op == op else {
        return MatcherResult(
          status: .fail,
          message: .expectedCustomValueTo("have \(op) operator", actual: exp.op)
        )
      }

      return try rhs.satisfies(
        Expression(expression: { exp.right }, location: input.location)
      )
    }
  }

  static func infix(
    _ lhs: ExpressionMatcher,
    _ op: String,
    _ rhs: ExpressionMatcher
  ) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? InfixExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be an infix expression")
        )
      }
      
      guard exp.op == op else {
        return MatcherResult(
          status: .fail,
          message: .expectedCustomValueTo("have \(op) operator", actual: exp.op)
        )
      }
      
      let res = try lhs.satisfies(
        Expression(expression: { exp.left }, location: input.location)
      )
      guard res.status == .matches else {
        return res
      }
      
      return try rhs.satisfies(
        Expression(expression: { exp.right }, location: input.location)
      )
    }
  }
  
  static func ident(_ name: String) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? IdentifierExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be an identifier expression")
        )
      }
      
      return MatcherResult(
        bool: exp.value == name,
        message: .expectedCustomValueTo("be named \(name)", actual: exp.value)
      )
    }
  }
  
  static func int(_ value: Int) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? IntegerExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be an integer expression")
        )
      }
      
      return MatcherResult(
        bool: exp.value == value,
        message: .expectedCustomValueTo("have value \(value)", actual: "\(exp.value)")
      )
    }
  }
  
  static func bool(_ value: Bool) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? BooleanExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a boolean expression")
        )
      }
      
      return MatcherResult(
        bool: exp.value == value,
        message: .expectedCustomValueTo("have value \(value)", actual: "\(exp.value)")
      )
    }
  }
}

extension ExpressionMatcher: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init { input in
      return try ExpressionMatcher.int(value).satisfies(input)
    }
  }
}

extension ExpressionMatcher: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init { input in
      return try ExpressionMatcher.bool(value).satisfies(input)
    }
  }
}

extension ExpressionMatcher: ExpressibleByUnicodeScalarLiteral {}
extension ExpressionMatcher: ExpressibleByExtendedGraphemeClusterLiteral {}
extension ExpressionMatcher: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init { input in
      return try ExpressionMatcher.ident(value).satisfies(input)
    }
  }
}
