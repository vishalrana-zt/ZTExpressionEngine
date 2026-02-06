public enum RuleError: Error, CustomStringConvertible {

    case unexpectedToken
    case unexpectedEOF
    case missingVariable(String)
    case typeMismatch(expected: String, got: Any)
    case invalidINOperand
    case invalidOperator(String)

    public var description: String {
        switch self {
        case .unexpectedToken:
            return "Unexpected token"
        case .unexpectedEOF:
            return "Unexpected end of expression"
        case .missingVariable(let name):
            return "Missing variable in rule context: \(name)"
        case .typeMismatch(let exp, let got):
            return "Type mismatch. Expected \(exp), got \(type(of: got))"
        case .invalidINOperand:
            return "Right-hand side of IN / NOT IN must be a list"
        case .invalidOperator(let op):
            return "Invalid operator: \(op)"
        }
    }
}

