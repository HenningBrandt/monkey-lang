import XCTest
import Nimble
@testable import MonkeyLang

final class ParserTests: XCTestCase {
  func testLetStatements() throws {
    try [
      ("let x = 5;", .let("x", 5)),
      ("let y = true;", .let("y", true)),
      ("let foobar = y;", .let("foobar", "y")),
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
      ("return 5;", .return(5)),
      ("return false;", .return(false)),
      ("return x;", .return("x")),
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
      ("3 + 4; -5 * 5", "(3 + 4);\n((-5) * 5)"),
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
      ("a + add(b * c) + d", "((a + add((b * c))) + d)"),
      ("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
      ("add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))")
    ].forEach { (input, expected) in
      let output = try Parser.parse(input)
      expect(output.description).to(equal(expected))
    }
  }
  
  func testIfExpression() throws {
    let statements = try Parser.parse("if (x < y) { x }").statements
    expect(statements).to(haveCount(1))
    expect(statements[0]).to(
      .expression(
        .if(
          .infix("x", "<", "y"),
          .block([.expression("x")])
        )
      )
    )
  }

  func testIfElseExpression() throws {
    let statements = try Parser.parse("if (x < y) { x } else { y }").statements
    expect(statements).to(haveCount(1))
    expect(statements[0]).to(
      .expression(
        .if(
          .infix("x", "<", "y"),
          .block([.expression("x")]),
          .block([.expression("y")])
        )
      )
    )
  }
  
  func testFunctionLiteral() throws {
    let statements = try Parser.parse("fn(x, y) { x + y; }").statements
    expect(statements).to(haveCount(1))
    expect(statements[0]).to(
      .expression(
        .fn(
          ["x", "y"],
          .block([.expression(.infix("x", "+", "y"))])
        )
      )
    )
  }
  
  func testFunctionParameters() throws {
    try [
      ("fn() {};", []),
      ("fn(x) {};", ["x"]),
      ("fn(x, y, z) {};", ["x", "y", "z"]),
    ].forEach { (input: String, params: [String]) in
      let statements = try Parser.parse(input).statements
      expect(statements).to(haveCount(1))
      expect(statements[0]).to(.expression(.fn(params, .block([]))))
    }
  }
  
  func testCallExpressions() throws {
    let statements = try Parser.parse("add(1, 2 * 3, 4 + 5);").statements
    expect(statements).to(haveCount(1))
    expect(statements[0]).to(
      .expression(
        .call(
          .ident("add"),
          [1, .infix("2", "*", "3"), .infix("4", "+", "5")]
        )
      )
    )
  }
}
