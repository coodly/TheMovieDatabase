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

internal class MoviesDiscoverRequest: NetworkRequest<Movie, Cursor<Movie>>, ConfigurationConsumer {
    var configuration: Configuration!
    
    private let page: Int
    private let discoverByKey: String
    private let discoverByValue: Int
    private let sort: SortBy
    
    init(genreId: Int, page: Int, sort: SortBy) {
        self.discoverByKey = "with_genres"
        self.discoverByValue = genreId
        self.page = page
        self.sort = sort
    }
    
    init(actorId: Int, page: Int, sort: SortBy) {
        self.discoverByKey = "with_cast"
        self.discoverByValue = actorId
        self.page = page
        self.sort = sort
    }
    
    override func execute() {
        var params: [String: AnyObject] = [
            "api_key": apiKey as AnyObject,
            "include_adult": false as AnyObject,
            "include_video": true as AnyObject,
            "page": page as AnyObject,
            "vote_count.gte": 50 as AnyObject,
            discoverByKey: discoverByValue as AnyObject]
        
        switch sort {
        case .none:
            break // no op
        default:
            params["sort_by"] = sort.value as AnyObject
        }
        GET(MovieDiscoverPath, parameters: params)
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

private extension SortBy {
    var value: String {
        switch self {
        case .none:
            return ""
        case .rating(let direction):
            return "vote_average.\(direction.rawValue)"
        case .popularity(let direction):
            return "popularity.\(direction.rawValue)"
        case .releaseDate(let direction):
            return "release_date.\(direction.rawValue)"
        }
    }
}
