//
//  ZipSearcherResults.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 4/27/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit

class wellTableCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var wellNameLabel: UILabel!
    @IBOutlet weak var toxicRankingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var wellNameTop: NSLayoutConstraint!
    
}

class ZipSearcherResults: UITableViewController {
    
    
    var wells: [WellShort] = []
    var numOfWells: Int = 10
    var noResults = false
    
    private var upArrowButton = UIButton()
    private var loadMore = UIButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
    }
    
    private func setupNavigationBarItems() {
        
//        upArrowButton = UIButton(type: .system)
//        upArrowButton.setImage(UIImage(named: "UpArrow"), for: .normal)
//        navigationItem.titleView = upArrowButton
//
//        let numWells = UILabel()
//        numWells.text = "Zip Searcher"
//        numWells.font = UIFont(name: "Futura", size: 20)
//        numWells.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
//        numWells.textAlignment = .center
////        numWells.textColor = UIColor(red: 52/255, green: 90/255, blue: 128/255, alpha: 1)
//        numWells.textColor = UIColor.white
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: numWells)
//
//        loadMore = UIButton(type: .system)
//        loadMore.setTitle("View More Entries", for: .normal)
//        loadMore.titleLabel?.font = loadMore.titleLabel?.font.withSize(15)
//        loadMore.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
//        loadMore.titleLabel?.textAlignment = .center
//        loadMore.tintColor = UIColor(red: 59/255, green: 131/255, blue: 226/255, alpha: 1)
//        loadMore.addTarget(self, action: #selector(ZipSearcherResults.loadeMoreButtonTapped), for: .touchUpInside)
//
//        if (!noResults) {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadMore)
//        }
//
////        navigationController?.navigationBar.backgroundColor = UIColor(red: 109/255, green: 182/255, blue: 220/255, alpha: 1)
//
//
//        upArrowButton.addTarget(self, action: #selector(ZipSearcherResults.upArrowTapped(button:)), for: .touchUpInside)

        
    }
    
    @objc private func loadeMoreButtonTapped() {
        let oldNumOfWells = numOfWells
        if wells.count < numOfWells + 10 {
            numOfWells = wells.count
        } else {
            numOfWells += 10
        }
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: NSIndexPath(row: oldNumOfWells - 1, section: 0) as IndexPath, at: .top, animated: true)
    }
    
    @objc func upArrowTapped(button: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numOfWells
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "well", for: indexPath) as! wellTableCell

        if (noResults) {
            cell.wellNameLabel.font = UIFont.systemFont(ofSize: 20)
            cell.wellNameLabel.text = "No Results"
            cell.wellNameTop.constant = CGFloat(35.0)
            cell.toxicRankingLabel.text = ""
            cell.distanceLabel.text = ""
        } else {
            cell.wellNameTop.constant = CGFloat(20.0)
            cell.wellNameLabel.text = wells[indexPath.row].well_name as String
            
            if wells[indexPath.row].toxicity > 0 {
                cell.toxicRankingLabel.text = "Toxicity Ranking: \(wells[indexPath.row].toxicity)"
            } else {
                cell.toxicRankingLabel.text = "Toxicity Ranking: NOT TOXIC"
            }
            
            cell.distanceLabel.text = "\(wells[indexPath.row].distance.round(to: 1)) miles"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;
    }
    
    
    // Handling Well Landing Page Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (!noResults) {
            let landingPage = segue.destination as! WellLandingPage
            landingPage.well.well_id = wells[tableView.indexPathForSelectedRow!.row].well_id
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!noResults) {
            self.performSegue(withIdentifier: "wellLandingPageSegue", sender: self)
        }
    }
    
    

}
