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

private let ListMovieGenresPath = "/genre/movie/list"

internal class ListMovieGenresRequest: NetworkRequest<Genre, [Genre]> {
    override func execute() {
        GET(ListMovieGenresPath, parameters: ["api_key": apiKey as AnyObject])
    }
    
    override func handle(success response: [String : AnyObject]) {
        guard let genres = response["genres"] as? [[String: AnyObject]] else {
            resulthandler(nil, nil)
            Logging.log("No genres element")
            return
        }
        
        var result = [Genre]()
        for genre in genres {
            guard let g = Genre(data: genre) else {
                continue
            }
            
            result.append(g)
        }
        
        resulthandler(result, nil)
    }
}
