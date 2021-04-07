//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-04-05.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
func test_init_doesNotMessageUponStoreCreation(){
        let (_, store) = MakeSUT()
    
        XCTAssertEqual(store.receivedmessages, [])
        
    }
func test_validateCache_deleteCacheOnRetreievalError(){
        let (sut, store) = MakeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedmessages, [.retrieve, .deleteCachedFeed])
    }
func test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut, store) = MakeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp =  fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
func test_validateCache_deleteSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp =  fixedCurrentDate.adding(days: -7)
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:sevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve, .deleteCachedFeed])
    }
func test_validateCache_deletesMoreThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp =  fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:moreThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasbeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store:store,currentDate: Date.init)
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
private func MakeSUT(currentDate: @escaping ()-> Date =  Date.init, file: StaticString =  #file, line: UInt = #line)-> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store  = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        return(sut, store)
    }
}
