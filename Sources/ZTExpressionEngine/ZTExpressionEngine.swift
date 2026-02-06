
import Foundation

public enum ZTExpressionEngine {

    public static func evaluate(
        _ expression: String,
        variables: [String: Any]
    ) throws -> Any {
        let normalizedVars = normalizeVariables(variables)
        return try ASTEvaluator.evaluate(expression, vars: normalizedVars)
    }
}
