//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-03-18.
//

import XCTest

extension XCTestCase{

    func trackFormemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. potential memory leak.", file: file, line: line)
        }
    }
}
