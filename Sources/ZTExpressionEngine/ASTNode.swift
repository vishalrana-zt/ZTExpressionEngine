public indirect enum ASTNode {
    case number(Double)
    case string(String)
    case variable(String)
    case list([ASTNode])
    case unary(op: Token, expr: ASTNode)
    case binary(op: Token, left: ASTNode, right: ASTNode)
    case ternary(condition: ASTNode, trueExpr: ASTNode, falseExpr: ASTNode)
}

