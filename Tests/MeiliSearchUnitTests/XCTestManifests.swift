/*
 This source file is part of the Swift.org open source project
 
 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(IndexesTests.allTests),
        testCase(DocumentsTests.allTests),
        testCase(SearchTests.allTests),
        testCase(UpdatesTests.allTests),
        testCase(KeysTests.allTests),
        testCase(SettingsTests.allTests),
        testCase(StatsTests.allTests),
        testCase(SystemTests.allTests),
        testCase(ClientTests.allTests)
    ]
}
#endif
