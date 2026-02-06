final class Parser {

    private let lexer: Lexer
    private var current: Token

    init(_ input: String) {
        lexer = Lexer(input)
        current = lexer.nextToken()
    }

    func parse() throws -> ASTNode {
        try parseTernary()
    }

    private func parseTernary() throws -> ASTNode {
        let condition = try parseOr()
        if current == .question {
            try consume()
            let t = try parseTernary()
            try consume(.colon)
            let f = try parseTernary()
            return .ternary(condition: condition, trueExpr: t, falseExpr: f)
        }
        return condition
    }

    private func parseOr() throws -> ASTNode {
        var node = try parseAnd()
        while current == .or {
            let op = current
            try consume()
            node = .binary(op: op, left: node, right: try parseAnd())
        }
        return node
    }

    private func parseAnd() throws -> ASTNode {
        var node = try parseComparison()
        while current == .and {
            let op = current
            try consume()
            node = .binary(op: op, left: node, right: try parseComparison())
        }
        return node
    }

    private func parseComparison() throws -> ASTNode {
        var node = try parseTerm()
        while current == .in || current == .notIn {
            let op = current
            try consume()
            node = .binary(op: op, left: node, right: try parseTerm())
        }
        return node
    }

    private func parseTerm() throws -> ASTNode {
        var node = try parseFactor()
        while current == .plus || current == .minus {
            let op = current
            try consume()
            node = .binary(op: op, left: node, right: try parseFactor())
        }
        return node
    }

    private func parseFactor() throws -> ASTNode {
        var node = try parseUnary()
        while current == .multiply || current == .divide {
            let op = current
            try consume()
            node = .binary(op: op, left: node, right: try parseUnary())
        }
        return node
    }

    private func parseUnary() throws -> ASTNode {
        if current == .not || current == .minus {
            let op = current
            try consume()
            return .unary(op: op, expr: try parseUnary())
        }
        return try parsePrimary()
    }

    private func parsePrimary() throws -> ASTNode {
        switch current {
        case .number(let v): try consume(); return .number(v)
        case .string(let v): try consume(); return .string(v)
        case .identifier(let v): try consume(); return .variable(v)
        case .leftBracket: return try parseList()
        case .leftParen:
            try consume()
            let expr = try parseTernary()
            try consume(.rightParen)
            return expr
        case .eof:
            throw RuleError.unexpectedEOF
        default:
            throw RuleError.unexpectedToken
        }
    }

    private func parseList() throws -> ASTNode {
        try consume(.leftBracket)
        var items: [ASTNode] = []
        while current != .rightBracket {
            items.append(try parsePrimary())
            if current == .comma { try consume() }
        }
        try consume(.rightBracket)
        return .list(items)
    }

    private func consume(_ expected: Token? = nil) throws {
        if let expected = expected, current != expected {
            throw RuleError.unexpectedToken
        }
        current = lexer.nextToken()
    }
}

