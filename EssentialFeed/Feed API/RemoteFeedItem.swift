//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Vikant on 2021-04-01.
//

import Foundation


internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
