final class Lexer {

    private let chars: [Character]
    private var index = 0

    init(_ input: String) {
        chars = Array(input)
    }

    func nextToken() -> Token {
        skipWhitespace()
        guard index < chars.count else { return .eof }

        let c = chars[index]

        if c.isNumber { return readNumber() }
        if c == "'" || c == "\"" { return readString() }
        if isIdentifierStart(c)  { return readIdentifier() }

        index += 1

        switch c {
        case "+": return .plus
        case "-": return .minus
        case "*": return .multiply
        case "/": return .divide
        case "?": return .question
        case ":": return .colon
        case "(": return .leftParen
        case ")": return .rightParen
        case "[": return .leftBracket
        case "]": return .rightBracket
        case ",": return .comma
        case "=":
            if match("=") { return .equal }
            return .equal
        case "!":
            if match("=") { return .notEqual }
            return .not
        case ">":
            if match("=") { return .greaterEqual }
            return .greater
        case "<":
            if match("=") { return .lessEqual }
            return .less
        default:
            return .eof
        }
    }

    private func skipWhitespace() {
        while index < chars.count && chars[index].isWhitespace {
            index += 1
        }
    }

    private func match(_ expected: Character) -> Bool {
        guard index < chars.count, chars[index] == expected else { return false }
        index += 1
        return true
    }

    private func readNumber() -> Token {
        let start = index
        while index < chars.count && (chars[index].isNumber || chars[index] == ".") {
            index += 1
        }
        return .number(Double(String(chars[start..<index]))!)
    }

    private func readString() -> Token {
        let quote = chars[index]
        index += 1
        let start = index
        while chars[index] != quote { index += 1 }
        let value = String(chars[start..<index])
        index += 1
        return .string(value)
    }
    
    private func isIdentifierStart(_ c: Character) -> Bool {
        c.isLetter || c.isNumber
    }

    private func isIdentifierChar(_ c: Character) -> Bool {
        c.isLetter || c.isNumber ||
        c == ":" || c == "/" || c == "_" ||
        c == "-" || c == "?"
    }

    private func readIdentifier() -> Token {
        let start = index
        var hasLetter = false

        while index < chars.count && isIdentifierChar(chars[index]) {
            if chars[index].isLetter {
                hasLetter = true
            }
            index += 1
        }

        let word = String(chars[start..<index])

        // If it's purely numeric, treat as number
        if !hasLetter, let num = Double(word) {
            return .number(num)
        }

        switch word.uppercased() {
        case "AND": return .and
        case "OR": return .or
        case "NOT": return .not
        case "IN": return .in
        default:
            return .identifier(word)
        }
    }
}

