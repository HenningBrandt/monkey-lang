import XCTest
import Nimble
@testable import MonkeyLang

final class LexerTests: XCTestCase {
    func testNextToken() throws {
      let lexer = Lexer(
        """
        let five = 5;
        let ten = 10;
        
        let add = fn(x, y) {
          x + y;
        };
        
        let result = add(five, ten);
        !-/*5;
        5 < 10 > 5;
        
        if (5 < 10) {
          return true;
        } else {
          return false;
        }
        
        10 == 10;
        10 != 9;
        """
      )
      let expectedTokens: [Token] = [
        .let, .ident("five"), .assign, .int(5), .semicolon,
        .let, .ident("ten"), .assign, .int(10), .semicolon,
        .let, .ident("add"), .assign, .function, .lparen, .ident("x"), .comma, .ident("y"), .rparen, .lbrace,
        .ident("x"), .plus, .ident("y"), .semicolon,
        .rbrace, .semicolon,
        .let, .ident("result"), .assign, .ident("add"), .lparen, .ident("five"), .comma, .ident("ten"), .rparen, .semicolon,
        .bang, .minus, .slash, .asterisk, .int(5), .semicolon,
        .int(5), .lt, .int(10), .gt, .int(5), .semicolon,
        .if, .lparen, .int(5), .lt, .int(10), .rparen, .lbrace,
        .return, .true, .semicolon,
        .rbrace, .else, .lbrace,
        .return, .false, .semicolon,
        .rbrace,
        .int(10), .eq, .int(10), .semicolon,
        .int(10), .notEq, .int(9), .semicolon,
        .eof
      ]
      
      expect(Array(lexer)).to(equal(expectedTokens))
    }
}
