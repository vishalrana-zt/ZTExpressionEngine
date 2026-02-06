import XCTest
@testable import ZTExpressionEngine

final class ZTExpressionEngineTests: XCTestCase {

    func testRule() throws {

        let rule = """
        Type IN ['CG','CO']
        ? 12
        : (Type IN ['FOAM'] ? HydroDone + 5 : 0)
        """

        let result = try ASTEvaluator.evaluate(
            rule,
            vars: ["Type": "FOAM", "HydroDone": 7]
        )

        XCTAssertEqual(result as? Double, 12)
    }
}

