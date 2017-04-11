/*
 * Copyright 2017 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
@testable import TheMovieDatabase

class MovieTests: XCTestCase, JSONLoader {
    func testListMovieParse() {
        let data = self.json(from: "movie-in-list") as [String: AnyObject]
        
        let movie = Movie.loadFromData(0, data: data)
        XCTAssertNotNil(movie)
        XCTAssertNotNil(movie?.overview)
        XCTAssertNil(movie?.collection)
    }
    
    func testParseDetailsWithoutCollection() {
        let data = self.json(from: "movie-details-without-collection") as [String: AnyObject]
        
        let movie = Movie.loadFromData(0, data: data)
        XCTAssertNil(movie?.collection)
    }

    func testParseDetailsWithCollectionSummary() {
        let data = self.json(from: "movie-details-with-collection") as [String: AnyObject]
        
        let movie = Movie.loadFromData(0, data: data)
        XCTAssertNotNil(movie?.collection)
    }
}
