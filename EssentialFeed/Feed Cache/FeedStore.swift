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
    func insert (_ items :[FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    
}

