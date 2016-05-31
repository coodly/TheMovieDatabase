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

public class TMDB {
    private let apiKey: String
    private let fetch: NetworkFetch
    
    public init(apiKey: String, networkFetch: NetworkFetch) {
        self.apiKey = apiKey
        fetch = networkFetch
    }
    
    public func fetchTopMovies(completion: (Cursor<Movie>) -> ()) {
        Logging.log("Fetch top movies")
        fetchTopMovies(1, completion: completion)
    }
    
    public func fetchNextPage(cursor: Cursor<Movie>, completion: (Cursor<Movie> -> ())) {
        Logging.log("Fetch next page")
        fetchTopMovies(cursor.nextPage(), completion: completion)
    }
    
    public func detailsForMovie(movie: Movie, inclidedDetails details: Details = [], completion: (Movie, NSError?) -> ()) {
        Logging.log("Fetch details for movie:\(movie)")
        let request = FetchDetailsRequest(movie: movie, includedDetails: details, fetch: fetch)
        request.apiKey = apiKey
        request.resulthandler = {
            result, error in
            
            completion(result as! Movie, error)
        }
        request.execute()
    }
    
    private func fetchTopMovies(page: Int, completion: (Cursor<Movie> -> ())) {
        Logging.log("Fetch top movies on page: \(page)")
        let listRequest = ListTopMoviesRequest(page: page, fetch: fetch)
        listRequest.apiKey = apiKey
        listRequest.resulthandler = {
            result, error in
            
            if let cursor = result as? Cursor<Movie> {
                completion(cursor)
            }
        }
        listRequest.execute()
    }
}