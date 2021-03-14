//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Vikant on 2021-03-13.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol  FeedLoader {
    
    func load(completion: @escaping(LoadFeedResult)-> Void)
    
}
