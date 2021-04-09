//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-04-03.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedmessages, [])
    }
    func test_load_requestsCacheRetrieval(){
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
    func test_load_failsOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
    
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    func test_deliversNoImageOnEmptyCache(){
        let (sut, store) = makeSUT()
    
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    func test_load_deliversImageOnNonExpiredCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    func test_load_deliversNoImageOnCacheExpiration(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        })
    }
    func test_load_deliversNoImageOnExpiredCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
    }
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) =  makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
    func test_load_hasNoSideEffectsOnEmptyCache(){
        let (sut, store) = makeSUT()
        sut.load {_ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
    func test_load_hasNoSideEffectsOnNonExpirationCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        sut.load {_ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpirationTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
    func test_load_hasNoSideEffectsOnCacheExpiration(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let cacheExpirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        sut.load {_ in }
        store.completeRetrieval(with: feed.local, timestamp: cacheExpirationTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
    func test_load_hasNoSideEffectsOnExpiredTimestamp(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        sut.load {_ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
   // MARK: Helpers
    private func makeSUT(currentDate: @escaping ()-> Date = Date.init, file: StaticString =  #file, line:UInt = #line)->(sut: LocalFeedLoader, store:FeedStoreSpy){
        let store  = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        return(sut, store)
    }
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action:()-> Void, file: StaticString = #file, line: UInt = #line){
        let exp =  expectation(description: "Wait for load completions")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImage), .success(expectedImage)):
                XCTAssertEqual(receivedImage, expectedImage , file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError , file: file, line: line)
                
            default :
                
              XCTFail("Expected result\(expectedResult), got\(receivedResult) insted", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
  
}
