import Foundation

func toBool(_ value: Any) throws -> Bool {
    if let b = value as? Bool { return b }
    throw RuleError.typeMismatch(expected: "Bool", got: value)
}

func toDouble(_ value: Any) throws -> Double {
    if let d = value as? Double { return d }
    if let i = value as? Int { return Double(i) }
    throw RuleError.typeMismatch(expected: "Number", got: value)
}

