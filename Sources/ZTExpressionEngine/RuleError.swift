import Foundation

public enum RuleError: Error, CustomStringConvertible {

    // MARK: - Parsing errors

    case unexpectedToken(Token)
    case expectedToken(expected: Token, got: Token)
    case invalidOperator(String)

    // MARK: - Evaluation errors

    case missingVariable(String)
    case typeMismatch(expected: String, got: Any)
    case invalidINOperand
    case divisionByZero

    // MARK: - Description

    public var description: String {
        switch self {

        case .unexpectedToken(let token):
            return "Unexpected token: \(token)"

        case .expectedToken(let expected, let got):
            return "Expected token \(expected), got \(got)"

        case .invalidOperator(let op):
            return "Invalid operator: \(op)"

        case .missingVariable(let name):
            return "Missing variable in rule context: \(name)"

        case .typeMismatch(let expected, let got):
            return "Type mismatch. Expected \(expected), got \(type(of: got))"

        case .invalidINOperand:
            return "Right-hand side of IN operator must be a list"

        case .divisionByZero:
            return "Division by zero is not allowed"
        }
    }
}

