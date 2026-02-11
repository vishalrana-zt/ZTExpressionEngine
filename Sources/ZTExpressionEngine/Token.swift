import Foundation

public enum Token: Equatable, CustomStringConvertible {

    // MARK: - Literals

    case number(Double)
    case string(String)
    case identifier(String)

    // MARK: - Arithmetic

    case plus            // +
    case minus           // -
    case multiply        // *
    case divide          // /

    // MARK: - Logical

    case and             // AND
    case or              // OR
    case not             // NOT
    case logicalAnd      // &&
    case logicalOr       // ||

    // MARK: - Equality

    case equal            // ==
    case notEqual         // !=
    case strictEqual      // ===
    case strictNotEqual   // !==

    // MARK: - Comparison

    case greater          // >
    case greaterEqual     // >=
    case less             // <
    case lessEqual        // <=

    // MARK: - Membership

    case `in`             // IN
    case notIn            // NOT IN

    // MARK: - Ternary

    case question         // ?
    case colon            // :

    // MARK: - Grouping

    case leftParen        // (
    case rightParen       // )
    case leftBracket      // [
    case rightBracket     // ]

    // MARK: - Separator

    case comma            // ,

    // MARK: - End

    case eof
    case power   // **


    // MARK: - Debug / Description

    public var description: String {
        switch self {

        case .number(let v): return "number(\(v))"
        case .string(let v): return "string(\(v))"
        case .identifier(let v): return "identifier(\(v))"

        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "*"
        case .divide: return "/"
        case .power: return "**"

        case .and: return "AND"
        case .or: return "OR"
        case .not: return "NOT"
        case .logicalAnd: return "&&"
        case .logicalOr: return "||"

        case .equal: return "=="
        case .notEqual: return "!="
        case .strictEqual: return "==="
        case .strictNotEqual: return "!=="

        case .greater: return ">"
        case .greaterEqual: return ">="
        case .less: return "<"
        case .lessEqual: return "<="

        case .in: return "IN"
        case .notIn: return "NOT IN"

        case .question: return "?"
        case .colon: return ":"

        case .leftParen: return "("
        case .rightParen: return ")"
        case .leftBracket: return "["
        case .rightBracket: return "]"

        case .comma: return ","

        case .eof: return "EOF"
        }
    }
}

