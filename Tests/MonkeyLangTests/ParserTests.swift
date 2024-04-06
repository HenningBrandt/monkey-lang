import XCTest
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
    
    XCTAssertEqual(program.statements.count, 3)
    zip(program.statements, ["x", "y", "foobar"])
      .forEach(assertLetStatement(_:name:))
  }
  
  func testWrongLetStatements() throws {
    XCTAssertThrowsError(
      try Parser.parse(
        """
        let x 5;
        let y = 10;
        let foobar = 838383;
        """
      )
    )
  }
  
  func testReturnStatements() throws {
    let program = try Parser.parse(
      """
      return 5;
      return 10;
      return 838383;
      """
    )
      
    XCTAssertEqual(program.statements.count, 3)
    program.statements.forEach(assertReturnStatement(_:))
  }
  
  func testIndentifierExpression() throws {
    let program = try Parser.parse(
      """
      foobar;
      """
    )
    
    XCTAssertEqual(program.statements.count, 1)
    assertIdentifier(program.statements[0], name: "foobar")
  }
  
  // MARK: - Assertions
  
  private func assertLetStatement(_ statement: any Statement, name: String) {
    guard let statement = statement as? LetStatement else {
      XCTFail("Expected LetStatement but got \(type(of: statement))")
      return
    }
    
    XCTAssertEqual(statement.token.literal, "let")
    XCTAssertEqual(statement.name.value, name)
    XCTAssertEqual(statement.name.token.literal, name)
  }
  
  private func assertReturnStatement(_ statement: any Statement) {
    guard let statement = statement as? ReturnStatement else {
      XCTFail("Expected ReturnStatement but got \(type(of: statement))")
      return
    }
    
    XCTAssertEqual(statement.token.literal, "return")
  }
  
  private func assertIdentifier(_ statement: any Statement, name: String) {
    guard let statement = statement as? ExpressionStatement else {
      XCTFail("Expected ExpressionStatement but got \(type(of: statement))")
      return
    }
    guard let expression = statement.expression as? Identifier else {
      XCTFail("Expected Identifier but got \(type(of: statement.expression))")
      return
    }
    
    XCTAssertEqual(expression.value, name)
    XCTAssertEqual(expression.token.literal, name)
  }
}
