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

public typealias TMDBCompletionClosure = ((Cursor<Movie>?, Error?) -> ())

public class TMDB: InjectionHandler {
    public init(apiKey: String, networkFetch: NetworkFetch) {
        Injector.sharedInsatnce.apiKey = apiKey
        Injector.sharedInsatnce.networkFetch = networkFetch
    }
    
    fileprivate func runWithConfigCheck(request: NetworkRequest) {
        let injectAndRunClosure = {
            self.inject(into: request)
            request.execute()
        }
        
        if Injector.sharedInsatnce.configuration != nil {
            injectAndRunClosure()
            return
        }
        
        let configRequest = ConfigurationsRequest()
        inject(into: configRequest)
        configRequest.resulthandler = {
            result, error in

            if let error = error {
                request.handle(error: error)
                return
            }
            
            if let config = result as? Configuration {
                Injector.sharedInsatnce.configuration = config
                config.write()
            }
            
            injectAndRunClosure()
        }
        configRequest.execute()
    }
}

// MARK: - 
// MARK: Movie details
public extension TMDB {
    public func detailsFor(movie: Movie, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movie:\(movie)")
        detailsFor(movieId: movie.id, inclidedDetails: details, completion: completion)
    }
    
    public func detailsFor(movieId: Int, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movieId:\(movieId)")
        let request = FetchDetailsRequest(movieId: movieId, includedDetails: details)
        request.resulthandler = {
            result, error in
            
            completion(result as? Movie, error)
        }
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Lists
public extension TMDB {
    public func fetch(page: Int, in list: List, completion: @escaping TMDBCompletionClosure) {
        let request: NetworkRequest
        switch list {
        case .topRated:
            request = ListTopMoviesRequest(page: page)
        case .popular:
            request = ListPopularMoviesRequest(page: page)
        case .genre(let genreId):
            request = MoviesDiscoverRequest(genreId: genreId, page: page)
        case .search(let term):
            guard !term.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                completion(nil, nil)
                return
            }
            request = SearchMoviesRequest(page: page, term: term)
        case .actor(let actorId):
            request = MoviesDiscoverRequest(actorId: actorId, page: page)
        }
        
        request.resulthandler = {
            result, error in
            
            completion(result as? Cursor<Movie>, error)
        }
        
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Collections
public typealias TMDBCollectionClosure = ((Collection?) -> ())
public extension TMDB {
    public func fetch(colelction id: Int, completion: @escaping TMDBCollectionClosure) {
        let request = CollectionDetailsRequest(collectionId: id)
        request.resulthandler = {
            result, error in
            
            completion(result as? Collection)
        }
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Movie genres list
public extension TMDB {
    public func listMovieGenres(completion: @escaping ([Genre]) -> ()) {
        let request = ListMovieGenresRequest()
        inject(into: request)
        request.resulthandler = {
            result, error in
            
            let genres = result as? [Genre]
            completion(genres ?? [])
        }
        request.execute()
    }
}
