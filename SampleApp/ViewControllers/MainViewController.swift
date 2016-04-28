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

import UIKit

private let CellIdentifier = "CellIdentifier"

class MainViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    var tmdb: TheMovieDatabase!
    private var cursor: Cursor<Movie>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("main.controller.title", comment: "")
        
        tableView.registerNib(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tmdb.fetchTopMovies() {
            cursor in
            
            self.cursor = cursor
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cursor = cursor else {
            return 0
        }
        
        return cursor.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MovieCell
        
        let movie = cursor!.items[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = String(format: "%.2f", movie.rating)
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
}
