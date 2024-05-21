import Foundation
import CasePaths
import IdentifiedEnumCases

@CasePathable
@IdentifiedEnumCases
enum Token: Hashable {
  case illegal(String)
  case eof
  
  // Identifiers + literals
  case ident(String) // add, foobar, x, y, ...
  case int(Int) // 1343456
  
  // Operators
  case assign // =
  case plus // +
  case minus // -
  case bang // !
  case asterisk // *
  case slash // /
  case lt // <
  case gt // >
  case eq // ==
  case notEq // !=
  
  // Delimiters
  case comma // ,
  case semicolon // ;
  case lparen // (
  case rparen // )
  case lbrace // {
  case rbrace // }
  
  // Keywords
  case function
  case `let`
  case `true`
  case `false`
  case `if`
  case `else`
  case `return`
}

final class Lexer {
  // Whole input string
  private var input: String
  // Current characters position
  private var position: String.Index
  // Next character
  private var readPosition: String.Index
  // Current character
  private var char: Character = Character("\0")
  
  init(_ input: String) {
    self.input = input
    self.position = input.startIndex
    self.readPosition = input.startIndex

    if input.startIndex < input.endIndex {
      self.char = input[input.startIndex]
      self.readPosition = input.index(after: input.startIndex)
    }
  }
  
  private func nextToken() -> Token {
    skipWhitespace()

    let token: Token
    switch char {
    case "=":
      if peekChar() == "=" {
        token = .eq
        readChar()
      } else {
        token = .assign
      }
    case ";": token = .semicolon
    case "(": token = .lparen
    case ")": token = .rparen
    case ",": token = .comma
    case "+": token = .plus
    case "-": token = .minus
    case "!": 
      if peekChar() == "=" {
        token = .notEq
        readChar()
      } else {
        token = .bang
      }
    case "*": token = .asterisk
    case "/": token = .slash
    case "<": token = .lt
    case ">": token = .gt
    case "{": token = .lbrace
    case "}": token = .rbrace
    case "\0": token = .eof
    default:
      return readComplexToken()
    }
   
    readChar()
    return token
  }
  
  private func readChar() {
    guard readPosition < input.endIndex else {
      char = Character("\0")
      return
    }
    
    char = input[readPosition]
    position = readPosition
    self.readPosition = input.index(after: readPosition)
  }
  
  private func peekChar() -> Character? {
    guard readPosition < input.endIndex else { return nil }
    return input[readPosition]
  }
  
  private func readComplexToken() -> Token {
    if isIdentifier(char) {
      return readIdentifier()
    } else if char.isNumber {
      return readInt()
    } else {
      return .illegal(String(char))
    }
  }
  
  private func readIdentifier() -> Token {
    let startIndex = position
    while isIdentifier(char) {
      readChar()
    }
    let identifier = input[startIndex..<position]
    
    switch identifier {
    case "fn": return .function
    case "let": return .let
    case "true": return .true
    case "false": return .false
    case "if": return .if
    case "else": return .else
    case "return": return .return
    default: return .ident(String(identifier))
    }
  }
  
  private func readInt() -> Token {
    let startIndex = position
    while char.isNumber {
      readChar()
    }
    
    if let number = Int(input[startIndex..<position]) {
      return .int(number)
    } else {
      return .illegal(String(char))
    }
  }
  
  private func skipWhitespace() {
    while char.isWhitespace {
      readChar()
    }
  }
  
  private let identifierCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: "_"))

  private func isIdentifier(_ char: Character) -> Bool {
    guard let scalar = char.unicodeScalars.first else { return false }
    return identifierCharacters.contains(scalar)
  }
}

extension Token {
  var literal: String {
    switch self {
    case .illegal(let string): string
    case .eof: ""
    case .ident(let string): string
    case .int(let int): "\(int)"
    case .assign: "="
    case .plus: "+"
    case .minus: "-"
    case .bang: "!"
    case .asterisk: "*"
    case .slash: "/"
    case .lt: "<"
    case .gt: ">"
    case .eq: "=="
    case .notEq: "!="
    case .comma: ","
    case .semicolon: ";"
    case .lparen: "("
    case .rparen: ")"
    case .lbrace: "{"
    case .rbrace: "}"
    case .function: "fn"
    case .let: "let"
    case .true: "true"
    case .false: "false"
    case .if: "if"
    case .else: "else"
    case .return: "return"
    }
  }
}

extension Lexer: Sequence {
  final class Iterator: IteratorProtocol {
    private var reachedEof = false
    private let lexer: Lexer
    
    init(lexer: Lexer) {
      self.lexer = lexer
    }
  
    func next() -> Token? {
      guard !reachedEof else {
        return nil
      }
      let token = lexer.nextToken()
      reachedEof = token == .eof
      return token
    }
  }

  func makeIterator() -> Iterator {
    Iterator(lexer: self)
  }
}
