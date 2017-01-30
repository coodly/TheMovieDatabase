/*
 * Copyright 2016 Coodly LLC
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

import Foundation

private let MovieDiscoverPath = "/discover/movie"

internal class MoviesDiscoverRequest: NetworkRequest, ConfigurationConsumer {
    var configuration: Configuration!
    
    private let page: Int
    private let discoverByKey: String
    private let discoverByValue: Int
    
    init(genreId: Int, page: Int) {
        self.discoverByKey = "with_genres"
        self.discoverByValue = genreId
        self.page = page
    }
    
    init(actorId: Int, page: Int) {
        self.discoverByKey = "with_cast"
        self.discoverByValue = actorId
        self.page = page
    }
    
    override func execute() {
        GET(MovieDiscoverPath, parameters: ["api_key": apiKey as AnyObject, "sort_by": "popularity.desc" as AnyObject, "include_adult": false as AnyObject, "include_video": true as AnyObject, "page": page as AnyObject, discoverByKey: discoverByValue as AnyObject])
    }
    
    override func handle(success response: [String : AnyObject]) {
        let createMovieClosure: (Int, [String: AnyObject]) -> (Movie?) = {
            index, data in
            
            return Movie.loadFromData(index, data:data, config: self.configuration)
        }
        
        let cursor = Cursor<Movie>.loadFrom(response, creation: createMovieClosure)
        resulthandler(cursor, nil)
    }
}
