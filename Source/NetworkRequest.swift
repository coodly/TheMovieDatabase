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

private let APIServer = "http://api.themoviedb.org/3/"

class NetworkRequest {
    let fetch: NetworkFetch
    
    init(fetch: NetworkFetch) {
        self.fetch = fetch
    }
    
    func execute() {
        fatalError("Override \(#function)")
    }
    
    func GET(path: String) {
        
    }
    
    func POST(path: String) {
        
    }
    
    private func executeMethod(method: String, path: String) {
        let components = NSURLComponents(URL: NSURL(string: APIServer)!, resolvingAgainstBaseURL: true)!
        components.path = components.path!.stringByAppendingString(path)
        
        let requestURL = components.URL!
        Logging.log("execute \(method) to \(requestURL.absoluteString)")
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = method
        
        fetch.fetchRequest(request) {
            data, code, error in
        }
    }
}