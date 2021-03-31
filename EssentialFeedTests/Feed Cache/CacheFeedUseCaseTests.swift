//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-03-30.
//

import XCTest
import EssentialFeed



class CacheFeedUseCaseTests: XCTestCase {
    //MARK: Helpers
    
    func test_init_deosNotMessageStoreUponCreation(){
        let (_, store) =  MakeSUT()
        
        XCTAssertEqual(store.receivedmessages, [])
    }
    
    func test_save_requestCacheDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) =  MakeSUT()
        sut.save(items) { _ in }
        XCTAssertEqual(store.receivedmessages, [.deleteCachedFeed])
    }
    
    func test_save_deosNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) =  MakeSUT()
        let deletionError =  anyNSError()
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedmessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let timestamp = Date()
        let (sut, store) =  MakeSUT(currentDate: { timestamp})
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedmessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    func test_save_failsOnDeletioNError(){
        let (sut, store) =  MakeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toComppleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
        }
        
        func test_save_failsOnInsertionNError(){
            let (sut, store) =  MakeSUT()
            let insertionError = anyNSError()
            
            expect(sut, toComppleteWithError: insertionError, when: {
                store.completeDeletionSuccessfully()
                store.completeInsertion(with: insertionError)
            })
        
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let (sut, store) =  MakeSUT()
        expect(sut, toComppleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
            
        })
     }
    func test_save_DoesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store  =  FeedStoreSpy()
        var sut: LocalFeedLoader? =  LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]){ receivedResults.append($0)}
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
        
    }
    func test_save_DoesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store  =  FeedStoreSpy()
        var sut: LocalFeedLoader? =  LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]){ receivedResults.append($0)}
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
        
    }
    
    
    private func MakeSUT(currentDate: @escaping ()-> Date =  Date.init, file: StaticString =  #file, line: UInt = #line)-> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store  = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        return(sut, store)
    }
    
    private func expect (_ sut: LocalFeedLoader , toComppleteWithError expectedError: NSError?, when action: ()-> Void, file: StaticString = #file, line: UInt = #line){
        
        let exp =  expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError =  error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private class FeedStoreSpy: FeedStore  {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        private(set) var receivedmessages = [ReceivedMessage]()
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedmessages.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0){
            deletionCompletions[index](error)
        }
        func completeDeletionSuccessfully(at index: Int = 0){
            deletionCompletions[index](nil)
        }
        
        func insert( _ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion){
            insertionCompletions.append(completion)
            receivedmessages.append(.insert(items, timestamp))
        }
        func completeInsertion(with error: Error, at index: Int = 0){
            insertionCompletions[index](error)
        }
        func completeInsertionSuccessfully(at index: Int = 0){
            insertionCompletions[index](nil)
        }
    }
    
    private func uniqueItem()-> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    private func anyURL() -> URL{
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError()-> NSError {
        return NSError(domain: "any error", code: 0)
    }
}

