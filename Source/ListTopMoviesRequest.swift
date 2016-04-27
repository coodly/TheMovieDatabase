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

private let ListMoviesPath = "/movie/top_rated"

class ListTopMoviesRequest: NetworkRequest {
    override func execute() {
        GET(ListMoviesPath, parameters: ["api_key": apiKey])
    }
    
    override func handleSuccessResponse(data: [String : AnyObject]) {
        let createMovieClosure: ([String: AnyObject]) -> (Movie?) = {
            data in
            
            return Movie.loadFromData(data)
        }
        
        let cursor = Cursor<Movie>.loadFromData(data, creation: createMovieClosure)
        resulthandler(cursor, nil)
    }
}