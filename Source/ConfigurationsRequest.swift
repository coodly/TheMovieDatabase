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

private let ConfigurationsPath = "/configuration"

class ConfigurationsRequest: NetworkRequest {
    override func execute() {
        GET(ConfigurationsPath, parameters: ["api_key": apiKey])
    }
    
    override func handleSuccessResponse(_ data: [String : AnyObject]) {
        var result: Configuration? = nil
        defer {
            resulthandler(result, nil)
        }
        
        guard let images = data["images"] as? [String: AnyObject] else {
            Logging.log("No 'images' config")
            return
        }
        
        guard let base = images["secure_base_url"] as? String else {
            Logging.log("No base url string")
            return
        }
        
        guard let backdropSizes = images["backdrop_sizes"] as? [String] else {
            Logging.log("No backdrop sizes")
            return
        }

        guard let posterSizes = images["poster_sizes"] as? [String] else {
            Logging.log("No poster sizes")
            return
        }
    
        let backConfig = ImageConfiguration(baseURL: base, sizes: backdropSizes)
        let posterConfig = ImageConfiguration(baseURL: base, sizes: posterSizes)
        result = Configuration(backdropConfig: backConfig, posterConfig: posterConfig)
    }
}
