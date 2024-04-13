import XCTest
import Nimble
@testable import MonkeyLang

final class ASTTests: XCTestCase {
  func testDescription() throws {
    let program = Program(
      statements: [
        LetStatement(
          token: .let,
          name: IdentifierExpression(
            token: .ident("myVar"),
            value: "myVar"
          ),
          value: IdentifierExpression(
            token: .ident("anotherVar"),
            value: "anotherVar"
          )
        )
      ]
    )
    
    expect(program.description).to(equal("let myVar = anotherVar;"))
  }
}
