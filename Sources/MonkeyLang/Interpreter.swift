import Foundation

enum Interpreter {
  static func interpret(_ programText: String) throws -> Object {
    let lexer = Lexer(programText)
    let parser = Parser(lexer)
    let evaluator = Evaluator()
    
    let ast = try parser.parseProgram()
    return evaluator.eval(ast)
  }
}
