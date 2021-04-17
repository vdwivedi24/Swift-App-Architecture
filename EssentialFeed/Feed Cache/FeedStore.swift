//
//  FeedStore.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-03-31.
//

import Foundation


public enum RetrieveCacheFeedResult {
    case empty
    case found(feed:[LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacheFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsile to dispatch to appropriate therds, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsile to dispatch to appropriate therds, if needed.
    func insert (_ feed :[LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsile to dispatch to appropriate therds, if needed.
    func retrieve(completion:@escaping RetrievalCompletion)
}




