//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Vikant on 2021-03-13.
//


// We created this public struct and initializers because we need to create the FeedItems from the test fucnctions
import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
