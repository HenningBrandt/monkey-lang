import Foundation
import MonkeyLang

@main
struct Main {
  static func main() {
    let username = NSUserName()
    print("Hello \(username)! This is the Monkey programming language!")
    print("Feel free to type in commands\n")
    Repl().start()
  }
}
