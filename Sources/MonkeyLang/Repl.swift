import Foundation

public final class Repl {
  private static let prompt = ">> "

  public init() { }

  public func start() {
    print(Self.prompt, terminator: "")
    while let line = readLine(strippingNewline: true) {
      let lexer = Lexer(line)
      for token in lexer {
        print(token)
      }
      print(Self.prompt, terminator: "")
    }
  }
}
