import Foundation
import Nimble
@testable import MonkeyLang

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

func beIdentifierExpressionWithName(_ name: String) -> Matcher<any Statement> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard
        let statement = actualValue as? ExpressionStatement,
        let expression = statement.expression as? IdentifierExpression
      else {
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

func beIntegerExpressionWithValue(_ value: Int) -> Matcher<any Statement> {
  Matcher { actualExpression in
    if let actualValue = try actualExpression.evaluate() {
      guard
        let statement = actualValue as? ExpressionStatement,
        let expression = statement.expression as? IntegerExpression
      else {
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
