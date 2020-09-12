/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
 */

import XCTest
@testable import MeiliSearchIntegrationTests
@testable import MeiliSearchUnitTests

var tests = [XCTestCaseEntry]()
#if INSTRUMENTED
tests += MeiliSearchIntegrationTests.allTests()
#else
tests += MeiliSearchUnitTests.allTests()
#endif
XCTMain(tests)
