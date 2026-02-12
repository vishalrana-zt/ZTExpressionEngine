
import XCTest
@testable import ZTExpressionEngine

final class ZTExpressionEngineTests: XCTestCase {

    // MARK: - Basic Arithmetic

    func testAdditionWithSpacedVariables() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Passed Tests + Failed Tests",
            variables: [
                "Passed Tests": 5.0,
                "Failed Tests": 12.0
            ]
        ) as? Double

        XCTAssertEqual(result, 17.0)
    }

    func testSubtraction() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Passed Tests - Failed Tests",
            variables: [
                "Passed Tests": 5.0,
                "Failed Tests": 12.0
            ]
        ) as? Double

        XCTAssertEqual(result, -7.0)
    }

    func testDivision() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Total Tests / 100",
            variables: [
                "Total Tests": 20.0
            ]
        ) as? Double

        XCTAssertEqual(result, 0.2)
    }

    func testMultiplication() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Passed Tests * Failed Tests",
            variables: [
                "Passed Tests": 5.0,
                "Failed Tests": 4.0
            ]
        ) as? Double

        XCTAssertEqual(result, 20.0)
    }

    func testPowerOperator() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Passed Tests ** 2",
            variables: [
                "Passed Tests": 3.0
            ]
        ) as? Double

        XCTAssertEqual(result, 9.0)
    }

    // MARK: - IN Operator

    func testINOperatorTrue() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Type IN ['CG', 'SP', 'WU-SP']",
            variables: [
                "Type": "CG"
            ]
        ) as? Bool

        XCTAssertEqual(result, true)
    }

    func testINOperatorFalse() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Type IN ['CG', 'SP']",
            variables: [
                "Type": "CO2"
            ]
        ) as? Bool

        XCTAssertEqual(result, false)
    }

    func testNOTINOperator() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Type NOT IN ['CG', 'SP']",
            variables: [
                "Type": "CO2"
            ]
        ) as? Bool

        XCTAssertEqual(result, true)
    }

    // MARK: - Ternary

    func testSimpleTernary() throws {
        let result = try ZTExpressionEngine.evaluate(
            "Type IN ['CG'] ? 10 : 0",
            variables: [
                "Type": "CG"
            ]
        ) as? Double

        XCTAssertEqual(result, 10)
    }

    func testNestedTernary() throws {
        let result = try ZTExpressionEngine.evaluate(
            """
            Type IN ['CG', 'CO'] ? 12 :
            (Type IN ['CO2', 'FOAM'] ? HydroDone + 5 : 0)
            """,
            variables: [
                "Type": "CO2",
                "HydroDone": 7.0
            ]
        ) as? Double

        XCTAssertEqual(result, 12.0)
    }

    // MARK: - Logical AND

    func testLogicalANDChain() throws {
        let result = try ZTExpressionEngine.evaluate(
            """
            Q1 === '✔' && Q2 === '✔' && Q3 === '✔'
            """,
            variables: [
                "Q1": "✔",
                "Q2": "✔",
                "Q3": "✔"
            ]
        ) as? Bool

        XCTAssertEqual(result, true)
    }

    func testComplexInspectionRule() throws {
        let result = try ZTExpressionEngine.evaluate(
            """
            PassAll === '✔' ? 'OK' :
            (Q1:Visible/Unobstructed === '✔' &&
             Q2:LockPin/Seal === '✔' &&
             Q3 === '✔' &&
             Q4 === '✔' &&
             Q5 === '✔' &&
             Q6 === '✔' ? 'OK' : 'Not OK')
            """,
            variables: [
                "PassAll": "",
                "Q1:Visible/Unobstructed": "✔",
                "Q2:LockPin/Seal": "✔",
                "Q3": "✔",
                "Q4": "✔",
                "Q5": "✔",
                "Q6": "✔"
            ]
        ) as? String

        XCTAssertEqual(result, "OK")
    }

    // MARK: - PSI Formula

    func testPSIFormula() throws {
        let result = try ZTExpressionEngine.evaluate(
            """
            29.84 * (Discharge Coefficient) *
            ((Nozzle Diameter) ** 2) *
            ((100% PSI) ** (1/2))
            """,
            variables: [
                "Discharge Coefficient": 1.0,
                "Nozzle Diameter": 2.0,
                "100% PSI": 4.0
            ]
        ) as? Double

        XCTAssertNotNil(result)
    }

    // MARK: - Error Handling

    func testMissingVariableThrows() {
        XCTAssertThrowsError(
            try ZTExpressionEngine.evaluate(
                "A + B",
                variables: ["A": 1.0]
            )
        )
    }

    func testDivisionByZeroThrows() {
        XCTAssertThrowsError(
            try ZTExpressionEngine.evaluate(
                "10 / 0",
                variables: [:]
            )
        )
    }
}
