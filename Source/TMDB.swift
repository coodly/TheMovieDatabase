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
    private var configuration: Configuration?
    
    public init(apiKey: String, networkFetch: NetworkFetch) {
        self.apiKey = apiKey
        fetch = networkFetch
    }
    
    public func fetchTopMovies(_ completion: @escaping (Cursor<Movie>) -> ()) {
        Logging.log("Fetch top movies")
        fetchTopMovies(1, completion: completion)
    }
    
    public func fetchNextPage(_ cursor: Cursor<Movie>, completion: @escaping ((Cursor<Movie>) -> ())) {
        Logging.log("Fetch next page")
        fetchTopMovies(cursor.nextPage(), completion: completion)
    }
    
    public func detailsFor(movie: Movie, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movie:\(movie)")
        detailsFor(movieId: movie.id, inclidedDetails: details, completion: completion)
    }

    public func detailsFor(movieId: Int, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movieId:\(movieId)")
        let request = FetchDetailsRequest(movieId: movieId, includedDetails: details, fetch: fetch)
        request.apiKey = apiKey
        request.resulthandler = {
            result, error in
            
            completion(result as? Movie, error)
        }
        request.execute()
    }

    private func fetchTopMovies(_ page: Int, completion: @escaping ((Cursor<Movie>) -> ())) {
        Logging.log("Fetch top movies on page: \(page)")
        let listRequest = ListTopMoviesRequest(page: page, fetch: fetch)
        listRequest.apiKey = apiKey
        listRequest.resulthandler = {
            result, error in
            
            if let cursor = result as? Cursor<Movie> {
                completion(cursor)
            }
        }
        runWithConfigCheck(request: listRequest)
    }
    
    private func runWithConfigCheck(request: ListTopMoviesRequest) {
        if configuration == nil {
            configuration = Configuration.load()
        }
        
        if let c = configuration {
            request.configuration = c
            request.execute()
            return
        }
        
        let configRequest = ConfigurationsRequest(fetch: fetch)
        configRequest.apiKey = apiKey
        configRequest.resulthandler = {
            result, error in

            if let config = result as? Configuration {
                self.configuration = config
                config.write()
            }
            
            request.configuration = self.configuration
            request.execute()
        }
        configRequest.execute()
    }
}
