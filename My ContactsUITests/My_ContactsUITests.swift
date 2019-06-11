//
//  My_ContactsUITests.swift
//  My ContactsUITests
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import XCTest


class My_ContactsUITests: XCTestCase {
    
    var app: XCUIApplication!


    override func setUp() {

        app = XCUIApplication()
        app.launch()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunch() {
        XCTAssert(app.navigationBars["Contacts"].exists)
    }
    func testCreateContact()
    {
        let scrollViewsQuery = app.scrollViews
        let myContactsCreatecontactviewNavigationBar = app.navigationBars["My_Contacts.CreateContactView"]
        
        let mobileTextField = scrollViewsQuery.otherElements.textFields["Enter Mobile No."]
        let nameTextField = scrollViewsQuery.otherElements.textFields["Enter Name"]
        let lastNameTf = scrollViewsQuery.otherElements.textFields["Enter Last Name"]
        let emaidTf = scrollViewsQuery.otherElements.textFields["Enter email Id"]
        let doneCreationButton = myContactsCreatecontactviewNavigationBar.buttons["Done"]
        let addContactsButton = app.navigationBars["Contacts"].buttons["Add"]
        let chooseImageSheet = app.sheets["Choose Image"]
        let chooseImageSheetCancelButton =  chooseImageSheet.buttons["Cancel"]
        let chooseImageSheetGalleryButton =  chooseImageSheet.buttons["Gallery"]
        addContactsButton.tap()
        nameTextField.tap()
        nameTextField.typeText("First name")
        doneCreationButton.tap()
        sleep(2)
        lastNameTf.tap()
        lastNameTf.typeText("Last Name test")
        mobileTextField.tap()
        mobileTextField.typeText("wrong mobile number")
        emaidTf.tap()
        emaidTf.typeText("eooeoe@gmail.com")
        app.scrollViews.otherElements.buttons["Button"].tap()
        chooseImageSheetGalleryButton.tap()
        sleep(5)
        selectPhoto()
        sleep(5)
        doneCreationButton.tap()
        mobileTextField.tap()
        mobileTextField.clearText()
        mobileTextField.typeText("9033427788")
        doneCreationButton.tap()
    }
    
    func testUpdateContact()
    {
        let cells = app.tables.cells
        sleep(10)
        XCTAssertTrue(cells.count > 0)
        
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
        let myContactsContactdetailviewNavigationBar = app.navigationBars["My_Contacts.ContactDetailView"]
        sleep(4)
        myContactsContactdetailviewNavigationBar.buttons["Edit"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let enterNameTextField = elementsQuery.textFields["Enter Name"]
        let lastNameTextField = elementsQuery.textFields["Enter Last Name"]
        let enterMobileNoTextField = elementsQuery.textFields["Enter Mobile No."]
        let enterEmailIdTextField = elementsQuery.textFields["Enter email Id"]
        
        enterNameTextField.tap()
        enterNameTextField.clearText()
        enterNameTextField.typeText("Samarth")
        lastNameTextField.tap()
        lastNameTextField.clearText()
        lastNameTextField.typeText("Kejriwal")
        enterMobileNoTextField.tap()
        enterMobileNoTextField.clearText()
        enterMobileNoTextField.typeText("9044528844")
        enterEmailIdTextField.tap()
        enterEmailIdTextField.clearText()
        enterEmailIdTextField.typeText("sam@gmail.com")
        sleep(2)
        app.navigationBars["My_Contacts.CreateContactView"].buttons["Done"].tap()
        sleep(5)
        myContactsContactdetailviewNavigationBar.buttons["Contacts"].tap()
        
    }
    
    func selectPhoto()
    {
        app.cells["Camera Roll"].tap()
        let collectionView = app.collectionViews["PhotosGridView"]
        collectionView.cells.element(boundBy: collectionView.cells.count - 1).tap()
    }

}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
