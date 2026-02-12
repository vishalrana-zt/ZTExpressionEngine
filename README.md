# ZTExpressionEngine

A lightweight, production-ready AST-based expression engine written in Swift.

ZTExpressionEngine safely evaluates dynamic business rules at runtime without relying on NSExpression.

It supports arithmetic, logical operators, ternary expressions, membership checks, and complex variable names — including variables with spaces, colons, and special characters.

---

## ✨ Features

- Arithmetic: + - * / **
- Logical operators: AND, OR, NOT, &&, ||
- Comparison: ==, !=, ===, !==, >, >=, <, <=
- Conditional (ternary): condition ? a : b
- Membership: IN, NOT IN
- Case-insensitive variable resolution
- Variables with spaces ("Passed Tests")
- Variables with colon ("Q1:Visible/Unobstructed")
- Variables with percent ("100% PSI")
- Nested expressions support
- Short-circuit logical evaluation
- Safe error handling (throws, no crashes)
- 100% unit test coverage
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

## 🧪 Test Coverage

ZTExpressionEngine includes a full automated test suite covering:

- Arithmetic operations
- Power operator
- IN / NOT IN
- Nested ternary expressions
- Logical short-circuiting
- Complex variable names
- Engineering formulas
- Error scenarios
- All tests passing.

---

## 🧠 How It Works

ZTExpressionEngine uses:

- A custom Lexer (tokenizer)
- A recursive descent Parser
- An AST (Abstract Syntax Tree)
- A safe Evaluator

No regex hacks. No NSExpression. Fully controlled parsing.

---

## 🧠 Design Notes

- Recursive-descent parser
- AST-based evaluation
- No NSExpression
- No runtime reflection
- Predictable evaluation order
- Production-safe by design

---

## 🔥 Why ZTExpressionEngine?

- Most dynamic rule engines:
- Break with complex variable names
- Fail on nested ternaries
- Can't handle IN
- Can't handle % or : variables

ZTExpressionEngine handles all of them.

---


## 📄 License

MIT License

Copyright (c) 2026 Vishal Rana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...

---
