//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-04-05.
//

import Foundation
import EssentialFeed

func uniqueImageFeed()-> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}
 func uniqueItems()-> (models:[FeedImage], local:[LocalFeedImage]){
    let models = [uniqueImageFeed(), uniqueImageFeed()]
    let local =  models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return(models, local)
}
 
 extension Date {
    func adding(days: Int)-> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .day,value: days, to: self)!
    }
    func adding(seconds: TimeInterval)-> Date {
        return self + seconds
    }
}

