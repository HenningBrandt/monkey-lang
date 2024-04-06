import Foundation

public final class Repl {
  private static let prompt = ">> "

  public init() { }

  public func start() {
    print(Self.prompt, terminator: "")
    while let line = readLine(strippingNewline: true) {
      let lexer = Lexer(line)
      var token = lexer.nextToken()
      while token != .eof {
        print(token)
        token = lexer.nextToken()
      }
      print(Self.prompt, terminator: "")
    }
  }
}
