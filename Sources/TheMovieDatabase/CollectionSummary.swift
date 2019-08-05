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

public struct CollectionSummary: Codable {
    public let id: Int
    public let name: String
    public var poster: Image? {
        return Image(path: posterPath, config: config.posterConfig)
    }
    public var backdrop: Image? {
        return Image(path: backdropPath, config: config.backdropConfig)
    }

    private let posterPath: String?
    private let backdropPath: String?
    
    private let config: Configuration
    
    public init(from decoder: Decoder) throws {
        guard let config = decoder.userInfo[.configuration] as? Configuration else {
            fatalError("Missing configuration or invalid configuration")
        }
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        posterPath = try? values.decode(String.self, forKey: .posterPath)
        backdropPath = try? values.decode(String.self, forKey: .backdropPath)
        
        self.config = config
    }
}
