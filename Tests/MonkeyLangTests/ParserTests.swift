import XCTest
@testable import MonkeyLang

final class ParserTests: XCTestCase {
  func testLetStatements() throws {
    let input = """
      let x = 5;
      let y = 10;
      let foobar = 838383;
      """
    
    let parser = Parser(Lexer(input))
    let program = try parser.parseProgram()
    
    XCTAssertEqual(program.statements.count, 3)
    zip(program.statements, ["x", "y", "foobar"])
      .forEach(assertLetStatement(_:name:))
  }
  
  func testWrongLetStatements() throws {
    let input = """
      let x 5;
      let y = 10;
      let foobar = 838383;
      """
    
    let parser = Parser(Lexer(input))
    XCTAssertThrowsError(try parser.parseProgram())
  }
  
  func testReturnStatements() throws {
    let input = """
      return 5;
      return 10;
      return 838383;
      """
    
    let parser = Parser(Lexer(input))
    let program = try parser.parseProgram()
    
    XCTAssertEqual(program.statements.count, 3)
    program.statements.forEach(assertReturnStatement(_:))
  }
  
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
}
