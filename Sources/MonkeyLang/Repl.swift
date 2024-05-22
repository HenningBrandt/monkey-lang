import Foundation

public final class Repl {
  private static let prompt = ">> "
  private static let monkeyFace = #"""
              __,__
     .--.  .-"     "-.  .--.
    / .. \/  .-. .-.  \/ .. \
   | |  '|  /   Y   \  |'  | |
   | \   \  \ 0 | 0 /  /   / |
    \ '- ,\.-"""""""-./, -' /
     ''-' /_   ^ ^   _\ '-''
         |  \._   _./  |
         \   \ '~' /   /
          '._ '-=-' _.'
             '-----'
  """#

  public init() { }

  public func start() {
    print(Self.prompt, terminator: "")
    while let line = readLine(strippingNewline: true) {
      do {
        let res = try Interpreter.interpret(line)
        print(res)
      } catch {
        printError(error)
      }
      print(Self.prompt, terminator: "")
    }
  }
  
  private func printError(_ error: Error) {
    print(Self.monkeyFace)
    print("Woops! We ran into some monkey business here!")
    print("\tparser errors:")
    print("\t\t\(error)")
  }
}
