import Foundation

final class Lexer {

    private var lastToken: Token = .eof
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

        // ----- Number OR identifier starting with number
        if c.isNumber {

            var tempIndex = index
            var isIdentifier = false

            while tempIndex < chars.count {
                let ch = chars[tempIndex]

                // If we see % followed by letter → unit label
                if ch == "%" {
                    var lookahead = tempIndex + 1
                    while lookahead < chars.count && chars[lookahead].isWhitespace {
                        lookahead += 1
                    }

                    if lookahead < chars.count && chars[lookahead].isLetter {
                        isIdentifier = true
                        break
                    }
                }

                if ch.isLetter {
                    isIdentifier = true
                    break
                }

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

            if isIdentifier {
                let token = readIdentifier()
                lastToken = token
                return token
            } else {
                let token = readNumber()
                lastToken = token
                return token
            }
        }

        // ----- String
        if c == "'" || c == "\"" {
            let token = readString()
            lastToken = token
            return token
        }

        // ----- Identifier start (IMPORTANT: % removed from here)
        if c.isLetter {
            let token = readIdentifier()
            lastToken = token
            return token
        }

        // ----- Modulus or identifier containing %
        if c == "%" {

            var lookahead = index + 1
            while lookahead < chars.count && chars[lookahead].isWhitespace {
                lookahead += 1
            }

            let nextStartsValue =
                lookahead < chars.count &&
                (chars[lookahead].isNumber || chars[lookahead].isLetter || chars[lookahead] == "(")

            let prevIsValue: Bool = {
                switch lastToken {
                case .number(_), .identifier(_), .rightParen, .rightBracket:
                    return true
                default:
                    return false
                }
            }()

            // Treat as modulus operator
            if prevIsValue && nextStartsValue {
                index += 1
                lastToken = .modulus
                return .modulus
            }

            // Otherwise part of identifier like CG%Value or 100% PSI
            let token = readIdentifier()
            lastToken = token
            return token
        }

        // consume single char operators
        index += 1

        switch c {

        case "+":
            lastToken = .plus
            return .plus

        case "-":
            lastToken = .minus
            return .minus

        case "/":
            lastToken = .divide
            return .divide

        case "*":
            if match("*") {
                lastToken = .power
                return .power
            }
            lastToken = .multiply
            return .multiply

        case "?":
            return .question

        case "(":
            lastToken = .leftParen
            return .leftParen

        case ")":
            lastToken = .rightParen
            return .rightParen

        case "[":
            lastToken = .leftBracket
            return .leftBracket

        case "]":
            lastToken = .rightBracket
            return .rightBracket

        case ",":
            return .comma

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
        let token = Token.number(Double(String(chars[start..<index])) ?? 0)
        lastToken = token
        return token
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

            if c == "%" {

                var lookahead = index + 1
                while lookahead < chars.count && chars[lookahead].isWhitespace {
                    lookahead += 1
                }

                if lookahead < chars.count &&
                    (chars[lookahead].isNumber || chars[lookahead] == "(") {
                    break   // stop identifier BEFORE %
                }
            }

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

        let token = Token.identifier(word)
        lastToken = token
        return token
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
