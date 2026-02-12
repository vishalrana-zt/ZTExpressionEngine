import Foundation

final class Lexer {

    private let chars: [Character]
    private var index = 0

    init(_ input: String) {
        chars = Array(input)
    }

    // MARK: - Public

    func nextToken() -> Token {
        skipWhitespace()
        guard index < chars.count else { return .eof }

        let c = chars[index]

        if c == ":" {
            index += 1
            return .colon
        }

        if c.isNumber {

            // Look ahead to decide if it's a pure number or identifier
            var tempIndex = index
            var hasLetter = false
            var hasPercent = false

            while tempIndex < chars.count {
                let ch = chars[tempIndex]

                if ch.isLetter { hasLetter = true }
                if ch == "%" { hasPercent = true }

                if ch.isWhitespace ||
                   ch == "+" || ch == "-" || ch == "*" || ch == "/" ||
                   ch == "(" || ch == ")" ||
                   ch == "[" || ch == "]" ||
                   ch == "," || ch == "?" ||
                   ch == "=" || ch == "!" || ch == "<" || ch == ">" ||
                   ch == "&" || ch == "|" {
                    break
                }

                tempIndex += 1
            }

            if hasLetter || hasPercent {
                return readIdentifier()
            } else {
                return readNumber()
            }
        }


        // ----- String
        if c == "'" || c == "\"" {
            return readString()
        }

        // ----- Identifier start
        if c.isLetter || c == "%" {
            return readIdentifier()
        }

        index += 1

        switch c {
        case "+": return .plus
        case "-": return .minus
        case "/": return .divide

        case "*":
            if match("*") { return .power }
            return .multiply

        case "?": return .question

        case "(": return .leftParen
        case ")": return .rightParen
        case "[": return .leftBracket
        case "]": return .rightBracket
        case ",": return .comma

        case "=":
            if match("=") {
                if match("=") { return .strictEqual }
                return .equal
            }
            return .equal

        case "!":
            if match("=") {
                if match("=") { return .strictNotEqual }
                return .notEqual
            }
            return .not

        case "&":
            if match("&") { return .logicalAnd }
            return .eof

        case "|":
            if match("|") { return .logicalOr }
            return .eof

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

    // MARK: Readers

    private func readNumber() -> Token {
        let start = index
        while index < chars.count &&
              (chars[index].isNumber || chars[index] == ".") {
            index += 1
        }
        return .number(Double(String(chars[start..<index])) ?? 0)
    }

    private func readString() -> Token {
        let quote = chars[index]
        index += 1
        let start = index

        while index < chars.count && chars[index] != quote {
            index += 1
        }

        let value = String(chars[start..<index])
        if index < chars.count { index += 1 }
        return .string(value)
    }

    private func readIdentifier() -> Token {

        let start = index

        while index < chars.count {

            let c = chars[index]

            // Stop at structural/operator characters ONLY
            if c.isWhitespace ||
               c == "+" || c == "-" || c == "*" ||
               c == "(" || c == ")" ||
               c == "[" || c == "]" ||
               c == "," || c == "?" ||
               c == "=" || c == "!" || c == "<" || c == ">" ||
               c == "&" || c == "|" {
                break
            }

            index += 1
        }

        let raw = String(chars[start..<index])
        let word = raw.trimmingCharacters(in: .whitespaces)

        if word.isEmpty {
            return .eof
        }

        let upper = word.uppercased()

        // Standalone keywords
        if upper == "AND" { return .and }
        if upper == "OR" { return .or }
        if upper == "IN" { return .in }

        if upper == "NOT" {
            let saved = index
            skipWhitespace()
            if let next = peekWord()?.uppercased(), next == "IN" {
                _ = readIdentifier()
                return .notIn
            }
            index = saved
            return .not
        }

        return .identifier(word)
    }

    // MARK: Helpers

    private func skipWhitespace() {
        while index < chars.count && chars[index].isWhitespace {
            index += 1
        }
    }

    private func match(_ c: Character) -> Bool {
        guard index < chars.count, chars[index] == c else { return false }
        index += 1
        return true
    }

    private func peek() -> Character? {
        guard index + 1 < chars.count else { return nil }
        return chars[index + 1]
    }

    private func peekWord() -> String? {
        var temp = index
        while temp < chars.count && chars[temp].isWhitespace {
            temp += 1
        }
        let start = temp

        while temp < chars.count {

            let c = chars[temp]

            if c == "+" || c == "-" || c == "*" || c == "/" ||
               c == "(" || c == ")" ||
               c == "[" || c == "]" ||
               c == "," || c == "?" || c == ":" ||
               c == "=" || c == "!" || c == "<" || c == ">" ||
               c == "&" || c == "|" {
                break
            }

            temp += 1
        }
        guard start < temp else { return nil }

        return String(chars[start..<temp])
            .trimmingCharacters(in: .whitespaces)
    }

    private func isIdentifierStart(_ c: Character) -> Bool {
        c.isLetter || c.isNumber
    }

    private func isIdentifierChar(_ c: Character) -> Bool {
        c.isLetter
            || c.isNumber
            || c == ":"
            || c == "/"
            || c == "_"
            || c == "-"
            || c == "?"
            || c == "%"
    }
}
