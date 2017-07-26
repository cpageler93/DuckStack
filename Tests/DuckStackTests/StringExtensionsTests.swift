//
//  StringExtensionsTests.swift
//  DuckStackTests
//
//  Created by Christoph Pageler on 26.07.17.
//

import XCTest
import DuckStack

class StringExtensionsTests: XCTestCase {
    
    func testCamelCasedString() {
        XCTAssertEqual("foo bar".camelCasedString() , "fooBar")
        XCTAssertEqual("foo bar ".camelCasedString() , "fooBar")
        XCTAssertEqual(" foo bar".camelCasedString() , "fooBar")
        XCTAssertEqual(" foo bar ".camelCasedString() , "fooBar")
        
        XCTAssertEqual("foo bar baz".camelCasedString() , "fooBarBaz")
    }
    
    func testSwiftClassName() {
        XCTAssertEqual("ToDo List".swiftClassName() , "ToDoList")
    }
    
}
