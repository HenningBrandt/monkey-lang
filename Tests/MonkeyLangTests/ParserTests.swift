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
      expect(program.statements[index]).to(beLetStatementWithName(name))
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
    expect(program.statements).to(allPass(beReturnStatement()))
  }
  
  func testIndentifierExpression() throws {
    let program = try Parser.parse(
      """
      foobar;
      """
    )
    
    expect(program.statements).to(haveCount(1))
    expect(program.statements[0]).to(
      beExpressionStatement(containing: identifierExpression(withName: "foobar"))
    )
  }
  
  func assertIntegerExpression() throws {
    let program = try Parser.parse(
      """
      5;
      """
    )
    
    expect(program.statements).to(haveCount(1))
    expect(program.statements[0]).to(
      beExpressionStatement(containing: integerExpression(withValue: 5))
    )
  }
  
  func testPrefixExpression() throws {
    let program = try Parser.parse(
      """
      !5;
      -15;
      """
    )
    
    expect(program.statements).to(haveCount(2))
    [("!", 5), ("-", 15)].enumerated().forEach { index, expected in
      let (op, operand) = expected
      expect(program.statements[index]).to(
        beExpressionStatement(
          containing: prefixExpression(
            withOperator: op,
            rhs: integerExpression(withValue: operand)
          )
        )
      )
    }
  }
  
  func testInfixExpressions() throws {
    let expressions = [
      (5, "+", 5),
      (5, "-", 5),
      (5, "*", 5),
      (5, "/", 5),
      (5, ">", 5),
      (5, "<", 5),
      (5, "==", 5),
      (5, "!=", 5),
    ]
    let program = try Parser.parse(
      expressions.reduce("") { str, expression in
        let (lhs, op, rhs) = expression
        return str + "\(lhs) \(op) \(rhs);"
      }
    )
    
    expect(program.statements).to(haveCount(8))
    expressions.enumerated().forEach { index, expected in
      let (lhs, op, rhs) = expected
      expect(program.statements[index]).to(
        beExpressionStatement(
          containing: infixExpression(
            withOperator: op,
            lhs: integerExpression(withValue: lhs),
            rhs: integerExpression(withValue: rhs)
          )
        )
      )
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
    ]
    for (input, expected) in expressions {
      let output = try Parser.parse(input)
      expect(output.description).to(equal(expected))
    }
  }
}
