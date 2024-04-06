import XCTest
@testable import MonkeyLang

final class ASTTests: XCTestCase {
  func testDescription() throws {
    let program = Program(
      statements: [
        LetStatement(
          token: .let,
          name: Identifier(
            token: .ident("myVar"),
            value: "myVar"
          ),
          value: Identifier(
            token: .ident("anotherVar"),
            value: "anotherVar"
          )
        )
      ]
    )
    
    XCTAssertEqual(program.description, "let myVar = anotherVar;")
  }
}
