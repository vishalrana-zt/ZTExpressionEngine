import Foundation

final class Parser {

    private let lexer: Lexer
    private var current: Token

    init(_ input: String) throws {
        self.lexer = Lexer(input)
        self.current = lexer.nextToken()
    }

    // MARK: - Entry point

    func parse() throws -> ASTNode {
        let expr = try parseTernary()
        try expect(.eof)
        return expr
    }

    // MARK: - Ternary

    private func parseTernary() throws -> ASTNode {
        let condition = try parseOr()
        if current == .question {
            try consume()
            let trueExpr = try parseTernary()
            try expect(.colon)
            let falseExpr = try parseTernary()
            return .ternary(condition: condition, trueExpr: trueExpr, falseExpr: falseExpr)
        }
        return condition
    }

    // MARK: - OR

    private func parseOr() throws -> ASTNode {
        var node = try parseAnd()
        while current == .or || current == .logicalOr {
            let op = current
            try consume()
            let right = try parseAnd()
            node = .binary(op: op, left: node, right: right)
        }
        return node
    }

    // MARK: - AND

    private func parseAnd() throws -> ASTNode {
        var node = try parseEquality()

        while current == .and || current == .logicalAnd {
            let op = current
            try consume()
            let right = try parseEquality()
            node = .binary(op: op, left: node, right: right)
        }

        return node
    }

    // MARK: - Equality (== != === !==)

    private func parseEquality() throws -> ASTNode {
        var node = try parseComparison()

        while current == .equal
            || current == .notEqual
            || current == .strictEqual
            || current == .strictNotEqual {

            let op = current
            try consume()
            let right = try parseComparison()
            node = .binary(op: op, left: node, right: right)
        }

        return node
    }

    // MARK: - Comparison (< > <= >= IN NOT IN)

    private func parseComparison() throws -> ASTNode {
        var node = try parseAdditive()

        while true {

            switch current {

            case .in, .notIn,
                 .greater, .greaterEqual,
                 .less, .lessEqual:

                let op = current
                try consume()

                let right = try parseAdditive()
                node = .binary(op: op, left: node, right: right)

            default:
                return node
            }
        }
    }

    // MARK: - Additive (+ -)

    private func parseAdditive() throws -> ASTNode {
        var node = try parseMultiplicative()

        while current == .plus || current == .minus {
            let op = current
            try consume()
            let right = try parseMultiplicative()
            node = .binary(op: op, left: node, right: right)
        }
        return node
    }

    // MARK: - Multiplicative (* /)

    private func parseMultiplicative() throws -> ASTNode {
        var node = try parsePower()

        while current == .multiply || current == .divide {
            let op = current
            try consume()
            let right = try parsePower()
            node = .binary(op: op, left: node, right: right)
        }

        return node
    }

    // MARK: - Power (right associative)

    private func parsePower() throws -> ASTNode {
        var node = try parseUnary()

        if current == .power {
            let op = current
            try consume()
            let right = try parsePower()
            node = .binary(op: op, left: node, right: right)
        }

        return node
    }

    // MARK: - Unary

    private func parseUnary() throws -> ASTNode {
        if current == .not || current == .minus {
            let op = current
            try consume()
            let expr = try parseUnary()
            return .unary(op: op, expr: expr)
        }
        return try parsePrimary()
    }

    // MARK: - Primary

    private func parsePrimary() throws -> ASTNode {
        switch current {

        case .number(let v):
            try consume()
            return .number(v)

        case .string(let v):
            try consume()
            return .string(v)

        case .identifier(let name):
            var fullName = name
            try consume()
            
            while case .identifier(let nextPart) = current {
                fullName += " " + nextPart
                try consume()
            }
            
            return .variable(fullName)

        case .leftParen:
            try consume()
            let expr = try parseTernary()
            try expect(.rightParen)
            return expr

        case .leftBracket:
            return try parseList()

        default:
            throw RuleError.unexpectedToken(current)
        }
    }

    private func parseList() throws -> ASTNode {
        try expect(.leftBracket)
        var items: [ASTNode] = []

        if current != .rightBracket {
            repeat {
                let value = try parseTernary()
                items.append(value)

                if current != .comma {
                    break
                }
                try consume()
            } while true
        }

        try expect(.rightBracket)
        return .list(items)
    }

    // MARK: - Helpers

    private func consume() throws {
        current = lexer.nextToken()
    }

    private func expect(_ token: Token) throws {
        guard current == token else {
            throw RuleError.unexpectedToken(current)
        }
        try consume()
    }
}

