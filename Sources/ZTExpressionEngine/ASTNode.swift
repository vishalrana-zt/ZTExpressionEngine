public indirect enum ASTNode {
    case number(Double)
    case string(String)
    case variable(String)
    case list([ASTNode])
    case unary(op: Token, expr: ASTNode)
    case binary(op: Token, left: ASTNode, right: ASTNode)
    case ternary(condition: ASTNode, trueExpr: ASTNode, falseExpr: ASTNode)
}

// MARK: - Debug description

extension ASTNode {

    func debugDescription(_ indent: String = "") -> String {
        let next = indent + "  "

        switch self {

        case .number(let v):
            return "\(indent)Number(\(v))"

        case .string(let v):
            return "\(indent)String(\(v))"

        case .variable(let name):
            return "\(indent)Variable(\(name))"

        case .list(let items):
            let inner = items.map { $0.debugDescription(next) }.joined(separator: "\n")
            return "\(indent)List[\n\(inner)\n\(indent)]"

        case .unary(let op, let expr):
            return """
            \(indent)Unary(\(op))
            \(expr.debugDescription(next))
            """

        case .binary(let op, let left, let right):
            return """
            \(indent)Binary(\(op))
            \(left.debugDescription(next))
            \(right.debugDescription(next))
            """

        case .ternary(let c, let t, let f):
            return """
            \(indent)Ternary
            \(c.debugDescription(next))
            \(t.debugDescription(next))
            \(f.debugDescription(next))
            """
        }
    }
}

