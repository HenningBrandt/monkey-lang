import XCTest
import Nimble
@testable import MonkeyLang

final class ParserTests: XCTestCase {
  func testLetStatements() throws {
    try [
      ("let x = 5;", .let("x")),
      ("let y = 10;", .let("y")),
      ("let foobar = 838383;", .let("foobar")),
    ].forEach { (input: String, matcher: StatementMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(matcher)
    }
  }
  
  func testWrongLetStatements() throws {
    expect {
      try Parser.parse(
        """
        let x 5;
        let y = 10;
        let foobar = 838383;
        """
      )
    }
    .to(throwError())
  }
  
  func testReturnStatements() throws {
    try [
      ("return 5;", .return()),
      ("return 10;", .return()),
      ("return 838383;", .return()),
    ].forEach { (input: String, matcher: StatementMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(matcher)
    }
  }

  func testIndentifierExpression() throws {
    try [
      ("foobar", "foobar"),
      ("foo", "foo"),
      ("baz", "baz"),
    ].forEach { (input: String, matcher: ExpressionMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(matcher))
    }
  }
  
  func testIntegerExpression() throws {
    try [
      ("5", 5),
      ("42", 42),
      ("123", 123),
    ].forEach { (input: String, matcher: ExpressionMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(matcher))
    }
  }
  
  func testBooleanExpression() throws {
    try [
      ("true", true),
      ("false", false),
    ].forEach { (input: String, matcher: ExpressionMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(matcher))
    }
  }
  
  func testPrefixExpression() throws {
    try [
      ("!5", .prefix("!", 5)),
      ("-15", .prefix("-", 15)),
      ("!true", .prefix("!", true)),
      ("!false", .prefix("!", false)),
    ].forEach { (input: String, matcher: ExpressionMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(matcher))
    }
  }
  
  func testInfixExpressions() throws {
    try [
      ("5 + 5", .infix(5, "+", 5)),
      ("5 - 5", .infix(5, "-", 5)),
      ("5 * 5", .infix(5, "*", 5)),
      ("5 / 5", .infix(5, "/", 5)),
      ("5 > 5", .infix(5, ">", 5)),
      ("5 < 5", .infix(5, "<", 5)),
      ("5 == 5", .infix(5, "==", 5)),
      ("5 != 5", .infix(5, "!=", 5)),
      ("true == true", .infix(true, "==", true)),
      ("true != false", .infix(true, "!=", false)),
      ("false == false", .infix(false, "==", false)),
    ].forEach { (input: String, matcher: ExpressionMatcher) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(matcher))
    }
  }

  func testOperatorPrecedenceParsing() throws {
    try [
      ("-a * b", "((-a) * b)"),
      ("!-a", "(!(-a))"),
      ("a + b + c", "((a + b) + c)"),
      ("a * b * c", "((a * b) * c)"),
      ("a + b / c", "(a + (b / c))"),
      ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
      ("3 + 4; -5 * 5", "(3 + 4)\n((-5) * 5)"),
      ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
      ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
      ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
      ("true", "true"),
      ("false", "false"),
      ("3 > 5 == false", "((3 > 5) == false)"),
      ("3 < 5 == true", "((3 < 5) == true)"),
      ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
      ("(5 + 5) * 2", "((5 + 5) * 2)"),
      ("2 / (5 + 5)", "(2 / (5 + 5))"),
      ("-(5 + 5)", "(-(5 + 5))"),
      ("!(true == true)", "(!(true == true))"),
    ].forEach { (input, expected) in
      let output = try Parser.parse(input)
      expect(output.description).to(equal(expected))
    }
  }
}
