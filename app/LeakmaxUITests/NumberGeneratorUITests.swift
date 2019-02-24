//
//  NumberGeneratorUITests.swift
//  LeakmaxUITests
//
//  Created by Ondrej Macoszek on 12/10/2018.
//  Copyright © 2018 com.showmax. All rights reserved.
//

import XCTest

class NumberGeneratorUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func test_openingGeneratorScreen() {

        for _ in 1...3 {
            openGenerator()
        }

        // Discussion/FYI:
        //
        // Good to know that Instruments will identify memory leak with second leaking object.
        // First leaking object is visible among allocations, but Instruments give no leak warning about first one.
        // You can verify this yourself by running (non-UI test scheme) app via Product > Profile > Leaks.
        //
        // Without calling `doOpenGenerator` for second time, we would have miss this leak.
        // Thus in order to help Instruments to pop out leaks, we have to repeat test at least twice.
        // In this test has repeating also another meaning, but elsewhere it would need to be just dummy repeating.
    }

    // MARK: - Helpers

    private func openGenerator() {
        let app = XCUIApplication()
        // Open generator screen
        app.buttons["Generate number"].tap()
        // Wait for number being generated.
        let label = app.staticTexts["number-label"]
        let isNotEmpty = NSPredicate(format: "label.length > 0")
        expectation(for: isNotEmpty, evaluatedWith: label, handler: nil)
        // Fail if not generated within 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
        // Dismiss generator screen
        app.buttons["Dismiss"].tap()
    }
}
