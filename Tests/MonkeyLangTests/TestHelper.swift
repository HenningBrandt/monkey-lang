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
  
  static func block(_ matchers: [StatementMatcher]) -> StatementMatcher {
    Matcher { input in
      guard let statement = try input.evaluate() as? BlockStatement else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a block statement")
        )
      }
      
      guard matchers.count == statement.statements.count else {
        return MatcherResult(
          status: .fail,
          message: .expectedTo("receive a matcher for every statement")
        )
      }
      
      for (index, matcher) in matchers.enumerated() {
        let res = try matcher.satisfies(
          Expression(expression: { statement.statements[index] }, location: input.location)
        )
        if res.status != .matches {
          return res
        }
      }
      
      return MatcherResult(bool: true, message: .expectedTo(""))
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
  
  static func `if`(
    _ condition: ExpressionMatcher,
    _ consequence: StatementMatcher,
    _ alternative: StatementMatcher? = nil
  ) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? IfExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be an if expression")
        )
      }
      
      let condRes = try condition.satisfies(
        Expression(expression: { exp.condition }, location: input.location)
      )
      guard condRes.status == .matches else {
        return condRes
      }
      
      let consRes = try consequence.satisfies(
        Expression(expression: { exp.consequence }, location: input.location)
      )
      guard consRes.status == .matches else {
        return consRes
      }
      
      guard let expAlternative = exp.alternative else {
        return MatcherResult.init(bool: true, message: .expectedTo(""))
      }
      
      guard let alternative else {
        return MatcherResult(
          status: .fail,
          message: .expectedTo("receive alternative matcher")
        )
      }

      return try alternative.satisfies(
        Expression(expression: { expAlternative }, location: input.location)
      )
    }
  }
  
  static func fn(
    _ params: [String],
    _ body: StatementMatcher
  ) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? FunctionLiteral else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a function expression")
        )
      }
      
      let paramsRes =
        params.count == exp.parameters.count &&
        zip(params, exp.parameters).allSatisfy { name, identExpression in
          identExpression == IdentifierExpression(token: .ident(name), value: name)
        }
      guard paramsRes else {
        return MatcherResult(
          bool: paramsRes,
          message: .expectedCustomValueTo("match params list \(params)", actual: "\(exp.parameters)")
        )
      }

      return try body.satisfies(
        Expression(expression: { exp.body }, location: input.location)
      )
    }
  }
  
  static func call(
    _ function: ExpressionMatcher,
    _ args: [ExpressionMatcher]
  ) -> ExpressionMatcher {
    Matcher { input in
      guard let exp = try input.evaluate() as? CallExpression else {
        return MatcherResult(
          status: .fail,
          message: .expectedActualValueTo("be a call expression")
        )
      }
      
      let fnRes = try function.satisfies(
        Expression(expression: { exp.function }, location: input.location)
      )
      guard fnRes.status == .matches else {
        return fnRes
      }
      
      guard args.count == exp.arguments.count else {
        return MatcherResult(
          status: .fail,
          message: .expectedTo("match argument list")
        )
      }
      
      for (matcher, argExpression) in zip(args, exp.arguments) {
        let argRes = try matcher.satisfies(
          Expression(expression: { argExpression }, location: input.location)
        )
        guard argRes.status == .matches else {
          return fnRes
        }
      }
      
      return MatcherResult(bool: true, message: .expectedTo(""))
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
