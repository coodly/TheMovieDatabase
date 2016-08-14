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

public struct Image {
    let path: String?
    let config: ImageConfiguration?
    let apiKey: String?
    
    public func url(for size: String = "original") -> URL? {
        guard let path = path, let config = config, let apiKey = apiKey else {
            return nil
        }
        
        let usedSize: String
        if config.sizes.contains(size) {
            usedSize = size
        } else {
            Logging.log("\(size) not in \(config.sizes). Will use 'original'")
            usedSize = "original"
        }
        
        let result = "\(config.baseURL)\(usedSize)\(path)?api_key=\(apiKey)"
        return URL(string: result)
    }
}
