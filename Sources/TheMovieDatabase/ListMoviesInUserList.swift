/*
 * Copyright 2018 Coodly LLC
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

private let ListPathBase = "/list/"

internal struct MoviesListResult: Codable {
    let items: [Movie]
}

internal class ListMoviesInUserList: NetworkRequest<MoviesListResult, Cursor<Movie>>, ConfigurationConsumer {
    private var listId: Int
    var configuration: Configuration!
    
    init(listId: Int) {
        self.listId = listId
    }

    override func execute() {
        let path = "\(ListPathBase)\(listId)"
        GET(path, parameters: ["api_key": apiKey as AnyObject])
    }

    override func handle(response: MoviesListResult) {
        let cursor = Cursor(page: 1, totalPages: response.items.count, items: response.items)
        resulthandler(cursor, nil)
    }
}
