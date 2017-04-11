/*
 * Copyright 2017 Coodly LLC
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

public struct CollectionSummary {
    public let id: Int
    public let name: String
    public let poster: Image?
    public let backdrop: Image?
}

extension CollectionSummary {
    init?(data: [String: AnyObject], config: Configuration?) {
        guard let id = data["id"] as? Int else {
            return nil
        }
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        poster = Image(path: data["poster_path"] as? String, config: config?.posterConfig)
        backdrop = Image(path: data["backdrop_path"] as? String, config: config?.backdropConfig)
    }
}
