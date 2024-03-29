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

struct Configuration: Codable, Equatable {
    let images: ImagesConfig
    
    var backdropConfig: ImageConfiguration {
        return ImageConfiguration(baseURL: images.secureBaseUrl, sizes: images.backdropSizes)
    }

    var posterConfig: ImageConfiguration {
        return ImageConfiguration(baseURL: images.secureBaseUrl, sizes: images.posterSizes)
    }

    var profileConfig: ImageConfiguration {
        return ImageConfiguration(baseURL: images.secureBaseUrl, sizes: images.profileSizes)
    }
}

struct ImagesConfig: Codable, Equatable {
    let baseUrl: URL
    let secureBaseUrl: URL
    let backdropSizes: [String]
    let posterSizes: [String]
    let profileSizes: [String]
}
