/*
* Copyright 2020 Coodly LLC
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

internal struct VideosPage: Codable {
    let results: [Video]
}

public struct Video: Codable, Equatable {
    public enum Site: String, Codable, Equatable {
        case youtube = "YouTube"
        case vimeo = "Vimeo"
    }
    
    public enum VideoType: String, Codable, Equatable {
        case trailer = "Trailer"
        case teaser = "Teaser"
        case clip = "Clip"
        case featurette = "Featurette"
        case behindTheScenes = "Behind the Scenes"
        case bloopers = "Bloopers"
    }
    
    public let key: String
    public let name: String
    public let site: Site
    public let type: VideoType
}
