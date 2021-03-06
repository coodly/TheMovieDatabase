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

private let CollectionDetailsPath = "/collection"

class CollectionDetailsRequest: NetworkRequest<Collection, Collection>, ConfigurationConsumer {
    var configuration: Configuration!
    
    private let id: Int
    init(collectionId: Int) {
        id = collectionId
    }
    
    override func execute() {
        let path = "\(CollectionDetailsPath)/\(id)"
        GET(path, parameters: ["api_key": apiKey as AnyObject])
    }
    
    override func handle(response: Collection) {
        resulthandler(response, nil)
    }
}
