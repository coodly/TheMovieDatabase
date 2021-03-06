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

private let ListMoviesPath = "/movie/popular"

internal struct MoviesPage: Codable {
    let page: Int
    let totalPages: Int
    let results: [Movie]
    
    internal var cursor: Cursor<Movie> {
        return Cursor<Movie>(page: page, totalPages: totalPages, items: results)
    }
}

internal class ListPopularMoviesRequest: NetworkRequest<MoviesPage, Cursor<Movie>>, ConfigurationConsumer, CachedRequest {
    private var page: Int
    var configuration: Configuration!
    var cacheKey: String {
        return "popular-\(page)"
    }

    init(page: Int) {
        self.page = page
    }
    
    override func execute() {
        GET(ListMoviesPath, parameters: ["api_key": apiKey as AnyObject, "page": page as AnyObject])
    }
    
    override func handle(response: MoviesPage) {
        resulthandler(response.cursor, nil)
    }
}
