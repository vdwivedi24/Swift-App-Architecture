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
func test_validateCache_doesNotDeleteLessNonExpiredCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:nonExpiredTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve])
    }
func test_validateCache_deleteCacheOnExpiration(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:expirationTimestamp)
        XCTAssertEqual(store.receivedmessages, [.retrieve, .deleteCachedFeed])
    }
func test_validateCache_deletesExpiredCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredCacheTimestamp =  fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = MakeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp:expiredCacheTimestamp)
    XCTAssertEqual(store.receivedmessages, [.retrieve, .deleteCachedFeed])
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
