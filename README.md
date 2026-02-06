# ZTExpressionEngine

ZTExpressionEngine is a lightweight, AST-based expression engine written in Swift.
It evaluates dynamic business rules safely at runtime without relying on
NSExpression.

This library is designed for backend-driven rules, feature flags, pricing logic,
configuration rules, and conditional workflows.

---

## ✨ Features

- Arithmetic operations: + - * /
- Logical operators: AND, OR, NOT
- Conditional (ternary) expressions: condition ? a : b
- Membership checks: IN, NOT IN
- Case-insensitive variable resolution
- Unlimited nesting support
- AST-based parser (no regex hacks)
- Clear error reporting (throws, no crashes)
- Swift Package Manager compatible

---

## 📦 Installation (Swift Package Manager)

### Using Xcode

1. Open Xcode
2. Go to File → Add Packages…
3. Enter the repository URL:
   https://github.com/vishalrana-zt/ZTExpressionEngine
4. Select version Up to Next Major 1.0.0

---

### Using Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/vishalrana-zt/ZTExpressionEngine.git",
        from: "1.0.0"
    )
]
```

---

## 🚀 Usage

```swift
import ZTExpressionEngine

let expression = """
Type IN ['CG','CO']
? 12
: (Type IN ['FOAM'] ? HydroDone + 5 : 0)
"""

let result = try ZTExpressionEngine.evaluate(
    expression,
    variables: [
        "Type": "FOAM",
        "HydroDone": 7
    ]
)

print(result) // 12
```

---

## ❗ Error Handling

All errors are thrown as RuleError (no crashes):

```swift
do {
    let value = try ZTExpressionEngine.evaluate(expr, variables: vars)
} catch {
    print(error)
}
```

Example error:

Missing variable in rule context: HydroDone

---

## 🧠 Design Notes

- Recursive-descent parser
- AST-based evaluation
- No NSExpression
- No runtime reflection
- Predictable evaluation order
- Production-safe by design

---

## 📄 License

ZTExpressionEngine is released under the MIT License.
See the LICENSE file for details.
