import Foundation

func toBool(_ value: Any) throws -> Bool {
    if let b = value as? Bool { return b }
    throw RuleError.typeMismatch(expected: "Bool", got: value)
}

func toDouble(_ value: Any) throws -> Double {

    if let d = value as? Double { return d }
    if let i = value as? Int { return Double(i) }

    if let s = value as? String {
        if s.trimmingCharacters(in: .whitespaces).isEmpty {
            return 0.0   // treat empty as zero
        }
        if let d = Double(s) {
            return d
        }
    }

    throw RuleError.typeMismatch(expected: "Number", got: value)
}

public func normalizeVariables(_ vars: [String: Any]) -> [String: Any] {
    var normalized: [String: Any] = [:]

    for (key, value) in vars {
        if let s = value as? String, let d = Double(s) {
            normalized[key] = d
        } else {
            normalized[key] = value
        }
    }

    return normalized
}

extension String {
    func normalizedRuleString() -> String {
        self.replacingOccurrences(of: "''", with: "'")
    }
}

