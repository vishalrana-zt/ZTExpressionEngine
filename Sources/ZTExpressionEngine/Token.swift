public enum Token: Equatable {
    case number(Double)
    case string(String)
    case identifier(String)

    case plus, minus, multiply, divide
    case equal, notEqual
    case greater, less, greaterEqual, lessEqual
    case and, or, not
    case `in`, notIn

    case question, colon
    case leftParen, rightParen
    case leftBracket, rightBracket
    case comma
    case eof
    case logicalAnd   // &&
    case logicalOr    // ||

}

