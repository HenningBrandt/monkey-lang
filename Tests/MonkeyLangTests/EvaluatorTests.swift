import XCTest
import Nimble
@testable import MonkeyLang

final class EvaluatorTests: XCTestCase {
  func testEvalIntegerExpression() throws {
    try runTestCases([
      ("5", .int(5)),
      ("10", .int(10)),
      ("-5", .int(-5)),
      ("-10", .int(-10)),
      ("5 + 5 + 5 + 5 - 10", .int(10)),
      ("2 * 2 * 2 * 2 * 2", .int(32)),
      ("-50 + 100 + -50", .int(0)),
      ("5 * 2 + 10", .int(20)),
      ("5 + 2 * 10", .int(25)),
      ("20 + 2 * -10", .int(0)),
      ("50 / 2 * 2 + 10", .int(60)),
      ("2 * (5 + 10)", .int(30)),
      ("3 * 3 * 3 + 10", .int(37)),
      ("3 * (3 * 3) + 10", .int(37)),
      ("(5 + 10 * 2 + 15 / 3) * 2 + -10", .int(50)),
    ])
  }
  
  func testEvalBooleanExpression() throws {
    try runTestCases([
      ("true", .bool(true)),
      ("false", .bool(false)),
      ("1 < 2", .bool(true)),
      ("1 > 2", .bool(false)),
      ("1 < 1", .bool(false)),
      ("1 > 1", .bool(false)),
      ("1 == 1", .bool(true)),
      ("1 != 1", .bool(false)),
      ("1 == 2", .bool(false)),
      ("1 != 2", .bool(true)),
      ("true == true", .bool(true)),
      ("false == false", .bool(true)),
      ("true == false", .bool(false)),
      ("true != false", .bool(true)),
      ("false != true", .bool(true)),
    ])
  }
  
  func testBangOperator() throws {
    try runTestCases([
      ("!true", .bool(false)),
      ("!false", .bool(true)),
      ("!5", .bool(false)),
      ("!!true", .bool(true)),
      ("!!false", .bool(false)),
      ("!!5", .bool(true)),
    ])
  }
  
  func testIfElseExpression() throws {
    try runTestCases([
      ("if (true) { 10 }", .int(10)),
      ("if (false) { 10 }", .null),
      ("if (1) { 10 }", .int(10)),
      ("if (1 < 2) { 10 }", .int(10)),
      ("if (1 > 2) { 10 }", .null),
      ("if (1 > 2) { 10 } else { 20 }", .int(20)),
      ("if (1 < 2) { 10 } else { 20 }", .int(10)),
    ])
  }
  
  func testReturnStatement() throws {
    try runTestCases([
      ("return 10;", .int(10)),
      ("return 10; 9;", .int(10)),
      ("return 2 * 5; 9;", .int(10)),
      ("9; return 2 * 5; 9;", .int(10)),
      (
        """
        if (10 > 1) {
          if (10 > 1) {
            return 10;
          }
          return 1;
        }
        """,
        .int(10)
      )
    ])
  }

  private func runTestCases(_ testCases: [(String, Object)]) throws {
    try testCases.forEach { input, result in
      try expect(Interpreter.interpret(input)).to(equal(result))
    }
  }
}
