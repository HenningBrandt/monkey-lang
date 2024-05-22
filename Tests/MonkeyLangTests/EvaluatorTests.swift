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
    ].forEach { (input: String, result: Object) in
      try expect(Interpreter.interpret(input)).to(equal(result))
    }
  }
  
  func testEvalBooleanExpression() throws {
    try [
      ("true", .bool(true)),
      ("false", .bool(false)),
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
