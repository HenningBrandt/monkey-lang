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
        let program = try Parser.parse(line)
        print(program.description)
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
