import Foundation
import Nimble
@testable import MonkeyLang

// MARK: - Statement Matchers

func beLetStatementWithName(_ name: String) -> Matcher<any Statement> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let statement = actualValue as? LetStatement else {
        let message = ExpectationMessage
          .expectedActualValueTo("be a let statement")
        return MatcherResult(status: .fail, message: message)
      }
      guard statement.token.literal == "let" else {
        return MatcherResult(
          status: .fail,
          message: ExpectationMessage
            .expectedActualValueTo("have 'let' token")
        )
      }
      let result = statement.name.value == name && statement.name.token.literal == name
      return MatcherResult(
        bool: result,
        message: ExpectationMessage
          .expectedActualValueTo("be named \(name)")
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be a let statement")
          .appendedBeNilHint()
      )
    }
  }
}

func beReturnStatement() -> Matcher<any Statement> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let statement = actualValue as? ReturnStatement else {
        let message = ExpectationMessage
          .expectedActualValueTo("be a return statement")
        return MatcherResult(status: .fail, message: message)
      }
      let result = statement.token.literal == "return"
      return MatcherResult(
        bool: result,
        message: ExpectationMessage
          .expectedCustomValueTo("have 'return' token", actual: statement.token.literal)
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be a return statement")
          .appendedBeNilHint()
      )
    }
  }
}

func beExpressionStatement(
  containing expressionMatcher: Matcher<any MonkeyLang.Expression>
) -> Matcher<any Statement> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let statement = actualValue as? ExpressionStatement else {
        let message = ExpectationMessage
          .expectedActualValueTo("be an expression statement")
        return MatcherResult(status: .fail, message: message)
      }
      return try expressionMatcher.satisfies(
        Nimble.Expression(
          expression: { statement.expression },
          location: actualExpression.location
        )
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be an expression statement")
          .appendedBeNilHint()
      )
    }
  }
}

// MARK: - Expression Matchers

func identifierExpression(withName name: String) -> Matcher<any MonkeyLang.Expression> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let expression = actualValue as? IdentifierExpression else {
        let message = ExpectationMessage
          .expectedActualValueTo("be an identifier expression")
        return MatcherResult(status: .fail, message: message)
      }
      let result = expression.value == name && expression.token.literal == name
      return MatcherResult(
        bool: result,
        message: ExpectationMessage
          .expectedActualValueTo("be named \(name)")
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be an identifier expression")
          .appendedBeNilHint()
      )
    }
  }
}

func integerExpression(withValue value: Int) -> Matcher<any MonkeyLang.Expression> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let expression = actualValue as? IntegerExpression else {
        let message = ExpectationMessage
          .expectedActualValueTo("be an integer expression")
        return MatcherResult(status: .fail, message: message)
      }
      let result = expression.value == value && expression.token.literal == "\(value)"
      return MatcherResult(
        bool: result,
        message: ExpectationMessage
          .expectedActualValueTo("have value \(value)")
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be an integer expression")
          .appendedBeNilHint()
      )
    }
  }
}

func prefixExpression(
  withOperator op: String,
  rhs subExpressionMatcher: Matcher<any MonkeyLang.Expression>
) -> Matcher<any MonkeyLang.Expression> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let expression = actualValue as? PrefixExpression else {
        let message = ExpectationMessage
          .expectedActualValueTo("be a prefix expression")
        return MatcherResult(status: .fail, message: message)
      }
      guard expression.op == op && expression.token.literal == "\(op)" else {
        return MatcherResult(
          status: .fail,
          message: ExpectationMessage
            .expectedActualValueTo("have \(op) operator")
        )
      }
      return try subExpressionMatcher.satisfies(
        Expression(expression: { expression.right }, location: actualExpression.location)
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be a prefix expression")
          .appendedBeNilHint()
      )
    }
  }
}

func infixExpression(
  withOperator op: String,
  lhs lhsMatcher: Matcher<any MonkeyLang.Expression>,
  rhs rhsMatcher: Matcher<any MonkeyLang.Expression>
) -> Matcher<any MonkeyLang.Expression> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard let expression = actualValue as? InfixExpression else {
        let message = ExpectationMessage
          .expectedActualValueTo("be an infix expression")
        return MatcherResult(status: .fail, message: message)
      }
      guard expression.op == op && expression.token.literal == "\(op)" else {
        return MatcherResult(
          status: .fail,
          message: ExpectationMessage
            .expectedActualValueTo("have \(op) operator")
        )
      }
      
      let lhsRes = try lhsMatcher.satisfies(
        Expression(expression: { expression.left }, location: actualExpression.location)
      )
      if lhsRes.status == .matches {
        return lhsRes
      }

      return try rhsMatcher.satisfies(
        Expression(expression: { expression.right }, location: actualExpression.location)
      )
    } else {
      return MatcherResult(
        status: .fail,
        message: ExpectationMessage
          .expectedActualValueTo("be an prefix expression")
          .appendedBeNilHint()
      )
    }
  }
}
