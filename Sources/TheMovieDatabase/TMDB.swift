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
    
    fileprivate func runWithConfigCheck<Response: Codable, Result>(request: NetworkRequest<Response, Result>) {
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
            
            if let config = result {
                Injector.sharedInsatnce.configuration = config
                let cached = CachedConfiguration(configuration: config, time: Date())
                cached.write()
            }
            
            injectAndRunClosure()
        }
        configRequest.execute()
    }
}

// MARK: - 
// MARK: Movie details
extension TMDB {
    public func detailsFor(movie: Movie, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movie:\(movie)")
        detailsFor(movieId: movie.id, inclidedDetails: details, completion: completion)
    }
    
    public func detailsFor(movieId: Int, inclidedDetails details: Details = [], completion: @escaping (Movie?, Error?) -> ()) {
        Logging.log("Fetch details for movieId:\(movieId)")
        let request = FetchDetailsRequest(movieId: movieId, includedDetails: details)
        request.resulthandler = completion
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Lists
extension TMDB {
    public func fetch(page: Int, in list: List, sort: SortBy = .popularity(.desc), completion: @escaping TMDBCompletionClosure) {
        let request: NetworkRequest<MoviesPage, Cursor<Movie>>
        switch list {
        case .topRated:
            request = ListTopMoviesRequest(page: page)
        case .popular:
            request = ListPopularMoviesRequest(page: page)
        case .genre(let genreId):
            request = MoviesDiscoverRequest(genreId: genreId, page: page, sort: sort)
        case .search(let term):
            guard !term.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                completion(nil, nil)
                return
            }
            request = SearchMoviesRequest(page: page, term: term)
        case .actor(let actorId):
            request = MoviesDiscoverRequest(actorId: actorId, page: page, sort: sort)
        case .user(let listId):
            request = ListMoviesInUserList(listId: listId)
        }
        
        request.resulthandler = completion
        
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: By external ID
extension TMDB {
    public func findWithIMDB(id: String, completion: @escaping ((Movie?, Error?) -> Void)) {
        let request = FindWithIMDBRequest(imdbID: id)
        request.resulthandler = completion
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Collections
public typealias TMDBCollectionClosure = ((Collection?) -> ())
extension TMDB {
    public func fetch(collection id: Int, completion: @escaping TMDBCollectionClosure) {
        let request = CollectionDetailsRequest(collectionId: id)
        request.resulthandler = {
            result, error in
            
            completion(result)
        }
        runWithConfigCheck(request: request)
    }
}

// MARK: -
// MARK: Movie genres list
extension TMDB {
    public func listMovieGenres(completion: @escaping ([Genre]) -> ()) {
        let request = ListMovieGenresRequest()
        inject(into: request)
        request.resulthandler = {
            result, error in
            
            completion(result ?? [])
        }
        request.execute()
    }
}

extension TMDB {
    public func poster(with path: String?) -> Image {
        return Image(path: path, config: Injector.sharedInsatnce.configuration?.posterConfig)
    }
}
