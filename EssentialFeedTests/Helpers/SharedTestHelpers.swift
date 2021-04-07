//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Vikant on 2021-04-05.
//
import Foundation

func anyURL() -> URL{
   return URL(string: "http://any-url.com")!
}

func anyNSError()-> NSError {
   return NSError(domain: "any error", code: 0)
}
