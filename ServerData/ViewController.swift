//
//  ViewController.swift
//  ServerData
//
//  Created by Ashwin Tallapaka on 3/28/17.
//  Copyright © 2017 Ashwin Tallapaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var TBV: UITableView!
    
    var fetchCountry = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TBV.dataSource = self
        TBV.delegate = self 
        parseData()
        searchBar()
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    
    func searchBar()
    {
        let search = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        search.delegate = self
        search.showsScopeBar = true
        search.tintColor = UIColor.gray
        search.scopeButtonTitles = ["Country", "Capital"]
        self.TBV.tableHeaderView = search
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""
        {
            parseData()
        }
        else
        {
            if searchBar.selectedScopeButtonIndex == 0
            {
                fetchCountry = fetchCountry.filter({ (country) -> Bool in
                    return country.country.lowercased().contains(searchText.lowercased())
                })
            }
            else
            {
                    fetchCountry = fetchCountry.filter({ (country) -> Bool in
                        return country.capital.lowercased().contains(searchText.lowercased())
                    })
            }
        }
        self.TBV.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchCountry.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = TBV.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = fetchCountry[indexPath.row].country
        cell.detailTextLabel?.text = fetchCountry[indexPath.row].capital
        return cell
    }
    
    func parseData()
    {
        fetchCountry = [] // Writing this line of code to see whether Array is empty or not
        
       let url = "https://restcountries.eu/rest/v1/all"
        
        
        var request = URLRequest(url: URL(string: url)!) // This line suggests the URL exists
        
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print("Error")
            }else
            
            {
                do{
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                    
                    //print(fetchedData)
                    
                    
                    for eachFetchedCountry in fetchedData {
                        let eachCountry = eachFetchedCountry as! [String : Any]
                        
                        let country = eachCountry["name"] as! String //Downcast it as a String
                        let capital = eachCountry["capital"] as! String //Downcast it as a String
                        
                        self.fetchCountry.append(Country(country: country, capital: capital))
                    }
                    
                    self.TBV.reloadData()
                    
                   // print(self.fetchCountry)
                }
                
                catch{
                    print("Error 2")
                }
            }
        }
        
        task.resume()
    }
   }


class Country
{
    var country : String
    var capital : String
    
    init(country: String, capital: String) {
        self.country = country
        self.capital = capital
    }
}
