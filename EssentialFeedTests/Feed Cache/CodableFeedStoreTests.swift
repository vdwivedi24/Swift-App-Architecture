//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-04-10.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure(){
        let storeURL = testSpecificStoreURL()
        let sut =  makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false,encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    func test_insert_overridesPreviouslyInsertedCacheValues(){
        let sut = makeSUT()
        let firstInsertionError = insert((uniqueItems().local, Date()),to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueItems().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    func test_delete_hasNoSideEffectsOnEmptyCache(){
        let sut =  makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected ampty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    func test_insert_deliversErrorOnInsertionError(){
        let invalidStoreURL =  URL(string:"https://invalidStoreURL.com")!
        let sut =  makeSUT(storeURL: invalidStoreURL)
        let feed =  uniqueItems().local
        let timestamp = Date()
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve: .empty)
    }
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues(){
        let sut = makeSUT()
        let feed =  uniqueItems().local
        let timestamp =  Date()
        let exp =  expectation(description: "Wait for cache retrieval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "expected feed to be inserted successfully")
            sut.retrieve { retrieveResult in
             switch retrieveResult {
             case  let .found(retrievedFeed, retrievedTimestamp):
                XCTAssertEqual(retrievedFeed, feed)
                XCTAssertEqual(retrievedTimestamp, timestamp)
            default:
            XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) isntead")
            }
            exp.fulfill()
        }
        }
        wait(for: [exp], timeout: 1.0)
    }
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        insert((uniqueItems().local,Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError(){
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected cache deltion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially(){
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueItems().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueItems().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    // MARK: Helpers
    private func makeSUT(storeURL: URL? =  nil, file: StaticString = #file, line: UInt = #line)-> FeedStore{
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        return sut
    }
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore)-> Error?{
        let exp =  expectation(description: "Wait for completion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError =  receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error?{
        let exp =  expectation(description: "Wait for compeltion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCacheFeedResult,file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #file, line: UInt = #line){
        let exp =  expectation(description: "Wait for cache retrieval")
        sut.retrieve { retrievedResult in
            switch(expectedResult, retrievedResult){
            case  (.empty, .empty),(.failure,.failure):
            break
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
            exp.fulfill()
    }
        wait(for: [exp], timeout: 1.0)
    }
    private func testSpecificStoreURL()-> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
