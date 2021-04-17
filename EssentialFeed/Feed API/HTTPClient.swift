//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Vikant on 2021-03-15.
//

import Foundation
public enum HTTPClientResult {
    
    case success(Data, HTTPURLResponse)
    case failure(Error)
    
}
public protocol HTTPClient {
    /// The completion handler can be invoked in any thread
    /// Clients are responsile to dispatch to appropriate therds, if needed.
    func get(from url: URL,completion: @escaping (HTTPClientResult)-> Void)
}
