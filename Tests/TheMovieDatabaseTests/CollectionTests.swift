//
//  CollectionTests.swift
//  TheMovieDatabase
//
//  Created by Jaanus Siim on 11/04/2017.
//
//

import XCTest
@testable import TheMovieDatabase

class CollectionTests: XCTestCase, JSONLoader {
    func testLoadCollection() {
        let data = self.json(from: "movie-collection") as [String: AnyObject]
        
        let collection = Collection(json: data)
        XCTAssertNotNil(collection)
        XCTAssertEqual(3, collection?.movies.count)
    }
}
