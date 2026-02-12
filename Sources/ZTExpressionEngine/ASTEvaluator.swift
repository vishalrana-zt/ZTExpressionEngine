import Foundation

import Foundation

public struct ASTEvaluator {

    public static func evaluate(
        _ expression: String,
        vars: [String: Any]
    ) throws -> Any {
        
        let normalizedVars = normalizeVariables(vars)
        let ast = try Parser(expression).parse()

        #if DEBUG
        debugPrint("=== AST DEBUG ===")
        debugPrint(ast.debugDescription())
        #endif
        return try eval(ast, vars: normalizedVars)
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
                $0.key.compare(name, options: .caseInsensitive) == .orderedSame
            })?.value {
                return value
            }

            if let value = vars.first(where: {
                $0.key.lowercased().hasSuffix(name.lowercased())
            })?.value {
                return value
            }

            let normalize: (String) -> String = {
                $0.replacingOccurrences(of: " ", with: "")
                  .replacingOccurrences(of: "%", with: "")
                  .lowercased()
            }

            let target = normalize(name)

            if let value = vars.first(where: { normalize($0.key) == target })?.value {
                return value
            }

            throw RuleError.missingVariable(name)

        case .list(let items):
            return try items.map { try eval($0, vars: vars) }

        case .unary(let op, let expr):
            let value = try eval(expr, vars: vars)

            switch op {
            case .not:
                return try !toBool(value)
            case .minus:
                return try -toDouble(value)
            default:
                throw RuleError.invalidOperator("\(op)")
            }

        case .binary(let op, let l, let r):

            // Short-circuit AND
            if op == .and || op == .logicalAnd {
                let left = try toBool(eval(l, vars: vars))
                if !left { return false }
                return try toBool(eval(r, vars: vars))
            }

            // Short-circuit OR
            if op == .or || op == .logicalOr {
                let left = try toBool(eval(l, vars: vars))
                if left { return true }
                return try toBool(eval(r, vars: vars))
            }

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
                let divisor = try toDouble(right)
                if divisor == 0 { throw RuleError.divisionByZero }
                return try toDouble(left) / divisor
                
            case .modulus:
                let divisor = try toDouble(right)
                if divisor == 0 { throw RuleError.divisionByZero }
                return try toDouble(left).truncatingRemainder(dividingBy: divisor)

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
}
