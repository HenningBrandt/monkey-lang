import XCTest
import Nimble
@testable import MonkeyLang

final class EvaluatorTests: XCTestCase {
  func testEvalIntegerExpression() throws {
    try [
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
    ].forEach { (input: String, result: Object) in
      try expect(Interpreter.interpret(input)).to(equal(result))
    }
  }
  
  func testEvalBooleanExpression() throws {
    try [
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
    ].forEach { (input: String, result: Object) in
      try expect(Interpreter.interpret(input)).to(equal(result))
    }
  }
  
  func testBangOperator() throws {
    try [
      ("!true", .bool(false)),
      ("!false", .bool(true)),
      ("!5", .bool(false)),
      ("!!true", .bool(true)),
      ("!!false", .bool(false)),
      ("!!5", .bool(true)),
    ].forEach { (input: String, result: Object) in
      try expect(Interpreter.interpret(input)).to(equal(result))
    }
  }
}
