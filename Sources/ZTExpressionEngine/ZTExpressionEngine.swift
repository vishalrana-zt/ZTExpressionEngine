
import Foundation

public enum ZTExpressionEngine {

    public static func evaluate(
        _ expression: String,
        variables: [String: Any]
    ) throws -> Any {
        return try ASTEvaluator.evaluate(expression.normalizedRuleString(), vars: variables)
    }
}
