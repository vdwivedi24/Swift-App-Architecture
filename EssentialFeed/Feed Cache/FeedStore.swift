//
//  FeedStore.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-03-31.
//

import Foundation


public protocol FeedStore{
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert (_ feed :[LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

// DTO-- Data transfer



