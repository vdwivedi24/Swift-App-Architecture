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
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert (_ feed :[LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion:@escaping RetrievalCompletion)
}

// DTO-- Data transfer



