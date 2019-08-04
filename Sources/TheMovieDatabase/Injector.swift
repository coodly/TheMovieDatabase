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

internal protocol InjectionHandler {
    func inject(into: AnyObject)
}

internal extension InjectionHandler {
    func inject(into: AnyObject) {
        Injector.sharedInsatnce.inject(into: into)
    }
}

internal class Injector {
    static let sharedInsatnce = Injector()
    var apiKey: String!
    var networkFetch: NetworkFetch!
    var configuration: Configuration? = CachedConfiguration.load()?.configuration
    private lazy var cache: ListCache = {
        return ListCache()
    }()
    
    func inject(into: AnyObject) {
        if var consumer = into as? APIKeyConsumer {
            consumer.apiKey = apiKey
        }
        
        if var consumer = into as? NetworkFetchConsumer {
            consumer.fetch = networkFetch
        }
        
        if var consumer = into as? ConfigurationConsumer {
            consumer.configuration = configuration!
        }

        if var consumer = into as? ListCacheConsumer {
            consumer.cache = cache
        }
    }
}

internal protocol APIKeyConsumer {
    var apiKey: String! { get set }
}

internal protocol NetworkFetchConsumer {
    var fetch: NetworkFetch! { get set }
}

internal protocol ConfigurationConsumer {
    var configuration: Configuration! { get set }
}
