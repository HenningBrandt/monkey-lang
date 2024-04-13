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
    expect(program.statements[0]).to(beIdentifierExpressionWithName("foobar"))
  }
  
  func assertIntegerExpression() throws {
    let program = try Parser.parse(
      """
      5;
      """
    )
    
    expect(program.statements).to(haveCount(1))
    expect(program.statements[0]).to(beIntegerExpressionWithValue(5))
  }
}
