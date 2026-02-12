import Foundation

func toBool(_ value: Any) throws -> Bool {
    if let b = value as? Bool { return b }
    if let n = value as? Double { return n != 0 }

    if let s = value as? String {
        let lower = s.lowercased()
        if lower == "true" { return true }
        if lower == "false" { return false }
        if lower.isEmpty { return false }
    }

    throw RuleError.typeMismatch(expected: "Bool", got: value)
}

func toDouble(_ value: Any) throws -> Double {

    if let d = value as? Double { return d }
    if let i = value as? Int { return Double(i) }

    if let s = value as? String {
        if s.trimmingCharacters(in: .whitespaces).isEmpty {
            return 0.0   // treat empty as zero
        }
        if let d = Double(s) {
            return d
        }
    }

    throw RuleError.typeMismatch(expected: "Number", got: value)
}

public func normalizeVariables(_ vars: [String: Any]) -> [String: Any] {
    var normalized: [String: Any] = [:]

    for (key, value) in vars {
        if let s = value as? String, let d = Double(s) {
            normalized[key] = d
        } else {
            normalized[key] = value
        }
    }

    return normalized
}

public func needsWrapping(_ name: String) -> Bool {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    return name.rangeOfCharacter(from: allowed.inverted) != nil
}

public func wrapVariables(in expression: String, vars: [String: Any]) -> String {

    var output = ""
    let lexer = Lexer(expression)

    var previousWasIdentifier = false

    while true {
        let token = lexer.nextToken()

        switch token {

        case .identifier(let name):

            // preserve space between identifier parts
            if previousWasIdentifier {
                output += " "
            }

            let matchedKey = vars.keys.first {
                $0.caseInsensitiveCompare(name) == .orderedSame
            }

            if let key = matchedKey, needsWrapping(key) {
                output += "(\(key))"
            } else {
                output += name
            }

            previousWasIdentifier = true

        case .number(let v):
            output += String(v)
            previousWasIdentifier = false

        case .string(let s):
            output += "'\(s)'"
            previousWasIdentifier = false

        case .plus: output += "+"; previousWasIdentifier = false
        case .minus: output += "-"; previousWasIdentifier = false
        case .multiply: output += "*"; previousWasIdentifier = false
        case .divide: output += "/"; previousWasIdentifier = false
        case .modulus: output += "%"; previousWasIdentifier = false
        case .power: output += "**"; previousWasIdentifier = false

        case .and: output += " AND "; previousWasIdentifier = false
        case .or: output += " OR "; previousWasIdentifier = false
        case .not: output += " NOT "; previousWasIdentifier = false
        case .logicalAnd: output += "&&"; previousWasIdentifier = false
        case .logicalOr: output += "||"; previousWasIdentifier = false

        case .equal: output += "=="; previousWasIdentifier = false
        case .notEqual: output += "!="; previousWasIdentifier = false
        case .strictEqual: output += "==="; previousWasIdentifier = false
        case .strictNotEqual: output += "!=="; previousWasIdentifier = false

        case .greater: output += ">"; previousWasIdentifier = false
        case .greaterEqual: output += ">="; previousWasIdentifier = false
        case .less: output += "<"; previousWasIdentifier = false
        case .lessEqual: output += "<="; previousWasIdentifier = false

        case .in: output += " IN "; previousWasIdentifier = false
        case .notIn: output += " NOT IN "; previousWasIdentifier = false

        case .question: output += "?"; previousWasIdentifier = false
        case .colon: output += ":"; previousWasIdentifier = false

        case .leftParen: output += "("; previousWasIdentifier = false
        case .rightParen: output += ")"; previousWasIdentifier = false
        case .leftBracket: output += "["; previousWasIdentifier = false
        case .rightBracket: output += "]"; previousWasIdentifier = false
        case .comma: output += ","; previousWasIdentifier = false

        case .eof:
            return output
        }
    }
}



extension String {
    func normalizedRuleString() -> String {
        self.replacingOccurrences(of: "''", with: "'")
    }
}

