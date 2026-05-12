import XCTest

final class LivePursuitUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPRDScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-uiTestPRDScreenshots")
        addUIInterruptionMonitor(withDescription: "Location Permission") { alert in
            if alert.buttons["Allow While Using App"].exists {
                alert.buttons["Allow While Using App"].tap()
                return true
            }
            if alert.buttons["Allow Once"].exists {
                alert.buttons["Allow Once"].tap()
                return true
            }
            return false
        }
        app.launch()
        acceptLocationIfNeeded(app)

        try capture("01-home", app: app)

        let simModeSwitch = app.switches["Simulation Mode"]
        if simModeSwitch.waitForExistence(timeout: 5),
           (simModeSwitch.value as? String) == "0" {
            simModeSwitch.tap()
        }
        try capture("02-home-simulation-enabled", app: app)

        app.buttons["Navigate to a Contact"].tap()
        XCTAssertTrue(app.navigationBars["Choose a Contact"].waitForExistence(timeout: 5))
        try capture("03-contact-list", app: app)

        app.staticTexts["Simulated Destination"].tap()
        XCTAssertTrue(app.staticTexts["Simulation"].waitForExistence(timeout: 12))
        try capture("04-navigation-simulation-ready", app: app)

        let pursuitSegment = app.buttons["Pursuit"]
        if pursuitSegment.waitForExistence(timeout: 2) {
            pursuitSegment.tap()
        }

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 5))
        sleep(3)
        try capture("05-navigation-simulation-running", app: app)

        let hideButton = app.buttons["Hide simulation controls"]
        XCTAssertTrue(hideButton.waitForExistence(timeout: 5))
        hideButton.tap()
        XCTAssertTrue(app.buttons["Show simulation controls"].waitForExistence(timeout: 5))
        try capture("06-navigation-controls-hidden", app: app)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Choose a Contact"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Live Pursuit"].waitForExistence(timeout: 5))

        app.buttons["Share My Location"].tap()
        if app.buttons["Continue"].waitForExistence(timeout: 3) {
            try capture("07-location-education", app: app)
            app.buttons["Continue"].tap()
        }
        XCTAssertTrue(app.staticTexts["Share your live location"].waitForExistence(timeout: 8))
        try capture("08-sharing-status", app: app)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Live Pursuit"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        try capture("09-settings", app: app)
    }

    func testHomeToContactListAndBack() throws {
        let app = XCUIApplication()
        app.launch()

        let primaryCTA = app.buttons["Navigate to a Contact"]
        XCTAssertTrue(primaryCTA.waitForExistence(timeout: 5))
        primaryCTA.tap()

        let contactListTitle = app.navigationBars["Choose a Contact"]
        XCTAssertTrue(contactListTitle.waitForExistence(timeout: 5))

        let backButton = contactListTitle.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }

        let homeTitle = app.navigationBars["Live Pursuit"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
    }

    func testSimulationControlsAndMinimize() throws {
        let app = XCUIApplication()
        app.launch()

        let simModeSwitch = app.switches["Simulation Mode"]
        if simModeSwitch.waitForExistence(timeout: 5) {
            if (simModeSwitch.value as? String) == "0" {
                simModeSwitch.tap()
            }
        }

        let primaryCTA = app.buttons["Navigate to a Contact"]
        XCTAssertTrue(primaryCTA.waitForExistence(timeout: 5))
        primaryCTA.tap()

        let simulatedCell = app.staticTexts["Simulated Destination"]
        XCTAssertTrue(simulatedCell.waitForExistence(timeout: 5))
        simulatedCell.tap()

        let simulationHeader = app.staticTexts["Simulation"]
        XCTAssertTrue(simulationHeader.waitForExistence(timeout: 10))

        let pursuitSegment = app.buttons["Pursuit"]
        if pursuitSegment.exists {
            pursuitSegment.tap()
        }

        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))

        // Let the simulation run briefly so telemetry events can emit.
        sleep(3)

        let minimizeButton = app.buttons["Hide simulation controls"]
        XCTAssertTrue(minimizeButton.waitForExistence(timeout: 5))
        minimizeButton.tap()

        let restoreButton = app.buttons["Show simulation controls"]
        XCTAssertTrue(restoreButton.waitForExistence(timeout: 5))
        restoreButton.tap()
    }

    private func capture(_ name: String, app: XCUIApplication) throws {
        let outputPath = ProcessInfo.processInfo.environment["PRD_SCREENSHOT_DIR"]
            ?? "/Users/edwinbetancourt/Workspace/LivePursuit/docs/prd_screenshots"
        let outputURL = URL(fileURLWithPath: outputPath, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let screenshot = XCUIScreen.main.screenshot()
        try screenshot.pngRepresentation.write(to: outputURL.appendingPathComponent("\(name).png"))

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func acceptLocationIfNeeded(_ app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowOnce = springboard.buttons["Allow Once"]
        if allowOnce.waitForExistence(timeout: 2) {
            allowOnce.tap()
            return
        }

        let whileUsing = springboard.buttons["Allow While Using App"]
        if whileUsing.waitForExistence(timeout: 1) {
            whileUsing.tap()
        }
    }
}
