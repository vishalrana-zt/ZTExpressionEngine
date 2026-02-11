import Foundation

public struct ASTEvaluator {

    public static func evaluate(
        _ expression: String,
        vars: [String: Any]
    ) throws -> Any {

        let processed = autoWrapVariables(expression, vars: vars)

        #if DEBUG
        debugPrint("PREPROCESSED:", processed)
        #endif

        let ast = try Parser(processed).parse()

        #if DEBUG
        debugPrint("=== AST DEBUG ===")
        debugPrint(ast.debugDescription())
        #endif
        return try eval(ast, vars: vars)
    }

    private static func eval(_ node: ASTNode, vars: [String: Any]) throws -> Any {

        switch node {

        case .number(let v): return v
        case .string(let v): return v

        case .variable(let name):
            if let value = vars[name] {
                return value
            }
            if let value = vars.first(where: {
                $0.key.lowercased() == name.lowercased()
            })?.value {
                return value
            }
            throw RuleError.missingVariable(name)

        case .list(let items):
            return try items.map { try eval($0, vars: vars) }

        case .unary(let op, let expr):
            let v = try eval(expr, vars: vars)
            if op == .not { return try !toBool(v) }
            if op == .minus { return try -toDouble(v) }
            throw RuleError.invalidOperator("\(op)")

        case .binary(let op, let l, let r):
            let left = try eval(l, vars: vars)

            if op == .in || op == .notIn {
                guard let list = try eval(r, vars: vars) as? [Any] else {
                    throw RuleError.invalidINOperand
                }
                let lhs = String(describing: left).lowercased()
                let found = list.contains {
                    String(describing: $0).lowercased() == lhs
                }
                return op == .in ? found : !found
            }

            let right = try eval(r, vars: vars)
            
            switch op {

            case .plus:
                return try toDouble(left) + toDouble(right)

            case .minus:
                return try toDouble(left) - toDouble(right)

            case .multiply:
                return try toDouble(left) * toDouble(right)
                
            case .power:  
                return pow(try toDouble(left), try toDouble(right))

            case .divide:
                return try toDouble(left) / toDouble(right)

            case .and, .logicalAnd:
                return try toBool(left) && toBool(right)

            case .or, .logicalOr:
                return try toBool(left) || toBool(right)

            case .equal:
                return String(describing: left) == String(describing: right)

            case .notEqual:
                return String(describing: left) != String(describing: right)

            case .strictEqual:
                return type(of: left) == type(of: right)
                    && String(describing: left) == String(describing: right)

            case .strictNotEqual:
                return !(type(of: left) == type(of: right)
                    && String(describing: left) == String(describing: right))

            default:
                throw RuleError.invalidOperator("\(op)")
            }

        case .ternary(let c, let t, let f):
            return try toBool(eval(c, vars: vars))
                ? eval(t, vars: vars)
                : eval(f, vars: vars)
        }
    }
    
    private static func autoWrapVariables(
        _ expression: String,
        vars: [String: Any]
    ) -> String {

        var result = expression

        // Sort longest first to prevent partial collisions
        let keys = vars.keys.sorted { $0.count > $1.count }

        for key in keys {

            // Skip if already wrapped
            if result.contains("(\(key))") { continue }

            // Replace plain occurrences only
            result = result.replacingOccurrences(
                of: key,
                with: "(\(key))"
            )
        }

        return result
    }
}
