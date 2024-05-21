import XCTest
import Nimble
@testable import MonkeyLang

final class ParserTests: XCTestCase {
  func testLetStatements() throws {
    let program = try Parser.parse(
      """
      let x = 5;
      let y = 10;
      let foobar = 838383;
      """
    )
    
    expect(program.statements).to(haveCount(3))
    ["x", "y", "foobar"].enumerated().forEach { index, name in
      expect(program.statements[index]).to(.let(name))
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
    let program = try Parser.parse(
      """
      return 5;
      return 10;
      return 838383;
      """
    )
    
    expect(program.statements).to(haveCount(3))
    expect(program.statements).to(allPass(.return()))
  }
  
  func testIndentifierExpression() throws {
    let program = try Parser.parse(
      """
      foobar;
      """
    )
    
    expect(program.statements).to(haveCount(1))
    expect(program.statements[0]).to(.expression("foobar"))
  }
  
  func testIntegerExpression() throws {
    let program = try Parser.parse(
      """
      5;
      """
    )
    
    expect(program.statements).to(haveCount(1))
    expect(program.statements[0]).to(.expression(5))
  }
  
  func testBooleanExpression() throws {
    let program = try Parser.parse(
      """
      true;
      false;
      """
    )
  
    expect(program.statements).to(haveCount(2))
    expect(program.statements[0]).to(.expression(true))
    expect(program.statements[1]).to(.expression(false))
  }
  
  func testPrefixExpression() throws {
    let testCases: [(String, ExpressionMatcher)] = [
      ("!5", .prefix("!", 5)),
      ("-15", .prefix("-", 15)),
      ("!true", .prefix("!", true)),
      ("!false", .prefix("!", false)),
    ]
    let program = try Parser.parse(
      testCases.map(\.0).joined(separator: ";").appending(";")
    )
    
    expect(program.statements).to(haveCount(testCases.count))
    testCases.enumerated().forEach { index, testCase in
      expect(program.statements[index]).to(.expression(testCase.1))
    }
  }
  
  func testInfixExpressions() throws {
    let testCases: [(String, ExpressionMatcher)] = [
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
    ]
    let program = try Parser.parse(
      testCases.map(\.0).joined(separator: ";").appending(";")
    )
    
    expect(program.statements).to(haveCount(testCases.count))
    testCases.enumerated().forEach { index, testCase in
      expect(program.statements[index]).to(.expression(testCase.1))
    }
  }
  
  func testOperatorPrecedenceParsing() throws {
    let expressions = [
      ("-a * b;", "((-a) * b)"),
      ("!-a;", "(!(-a))"),
      ("a + b + c;", "((a + b) + c)"),
      ("a * b * c;", "((a * b) * c)"),
      ("a + b / c;", "(a + (b / c))"),
      ("a + b * c + d / e - f;", "(((a + (b * c)) + (d / e)) - f)"),
      ("3 + 4; -5 * 5;", "(3 + 4)\n((-5) * 5)"),
      ("5 > 4 == 3 < 4;", "((5 > 4) == (3 < 4))"),
      ("5 < 4 != 3 > 4;", "((5 < 4) != (3 > 4))"),
      ("3 + 4 * 5 == 3 * 1 + 4 * 5;", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
      ("true;", "true"),
      ("false;", "false"),
      ("3 > 5 == false;", "((3 > 5) == false)"),
      ("3 < 5 == true;", "((3 < 5) == true)"),
    ]
    for (input, expected) in expressions {
      let output = try Parser.parse(input)
      expect(output.description).to(equal(expected))
    }
  }
}
