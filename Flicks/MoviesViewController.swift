//
//  MoviesViewController.swift
//  Flicks
//
//  Created by John Okahata on 10/12/16.
//  Copyright © 2016 John Okahata. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Get the now playing movies data
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue:OperationQueue.main
        )
        
        // Show loading sign
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let requestError = errorOrNil {
                    self.networkErrorView.isHidden = false
                } else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                        }
                    }
                }
        });
        task.resume()
        // Do any additional setup after loading the view.
    }
    
    // Makes a network request for updated movie data
    // Updates the tableView with new data
    // Hides the refreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Get the now playing movies data
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue:OperationQueue.main
        )
        
        // Show loading sign
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                         completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                                                            MBProgressHUD.hide(for: self.view, animated: true)
                                                            
                                                            if let requestError = errorOrNil {
                                                                self.networkErrorView.isHidden = false
                                                            } else {
                                                                if let data = dataOrNil {
                                                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                        with: data, options:[]) as? NSDictionary {
                                                                        NSLog("response: \(responseDictionary)")
                                                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                        self.tableView.reloadData()
                                                                        refreshControl.endRefreshing()
                                                                    }
                                                                }
                                                            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        // Show movie title
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        // Show movie picture
        if let posterPath = movie["poster_path"] as? String {
            let baseImageUrl = "https://image.tmdb.org/t/p/w500/"
            let imageURL = URL(string: baseImageUrl + posterPath)
            cell.posterView.setImageWith(imageURL!)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailsViewController
        detailViewController.movie = movie

    }
 

}
