//
//  WellLandingPage.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 6/15/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit

class ingredientTableCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var toxinTargetIndicator: UIView!
    @IBOutlet weak var toxinTargetIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var ingredientNameTop: NSLayoutConstraint!
    @IBOutlet weak var pathwaysTargeted: UILabel!
    @IBOutlet weak var foodAdditiveImageView: UIImageView!
    @IBOutlet weak var toxicImageView: UIImageView!
    @IBOutlet weak var toxicLabel: UILabel!
    @IBOutlet weak var foodAdditiveImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var toxicImageViewWidth: NSLayoutConstraint!
    
    // Properties
    var loadingIcon = FlowerSpinner()
    
}

class WellLandingPage: UIViewController, UITableViewDelegate, UITableViewDataSource, Downloadable {
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wellNameLabel: UILabel!
    @IBOutlet weak var operatorNameLabel: UILabel!
    @IBOutlet weak var stateCountyLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ingredientsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    // Properties
    let model = WellModel()
    var ingredients: [Ingredient] = []
    var well: Well = Well(well_id: 0, well_name: "", operator_name: "", latitude: 0, longitude: 0, depth: 0, volume: 0, state: "", county: "")
    var noIngredients = true
    var loading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
        
        // Setting delegates to self
        self.ingredientsTableView.delegate = self
        self.ingredientsTableView.dataSource = self
        self.ingredientsViewHeight.constant = CGFloat(125.0)
        
        dataSetup()
    }
    
    func dataSetup() {
        
        let wellParams = ["well_id": well.well_id, "response_type": "well"] as [String : Any]
        self.model.downloadWells(parameters: wellParams, url: URLServices.wells)

        let ingredientParams = ["well_id": well.well_id, "response_type": "ingredients"] as [String: Any]
        self.model.downloadWells(parameters: ingredientParams, url: URLServices.wells)

    }
    
    func didReceiveData(data: Any) {
        
        DispatchQueue.main.async {
            
            if data is Well {
                self.well = data as! Well
                
                
                // Setting label text values based on well data
                self.wellNameLabel.text = self.well.well_name
                self.operatorNameLabel.text = self.well.operator_name
                self.stateCountyLabel.text = "\(self.well.county), \(self.well.state)"
                self.longitudeLabel.text = "\(self.well.longitude.round(to: 4))"
                self.latitudeLabel.text = "\(self.well.latitude.round(to: 4))"
                self.depthLabel.text = "\(Int(self.well.depth))"
                self.volumeLabel.text = "\(Int(self.well.volume))"
            }
            
            if data is [Ingredient] {
                
                if (data as! [Ingredient]).count > 0 {
                    self.noIngredients = false
                    self.ingredients = data as! [Ingredient]
                    self.ingredientsViewHeight.constant = CGFloat(45.0 + Double(self.ingredients.count) * 80.0)
                }
                
                self.loading = false
                
                self.ingredientsTableView.reloadData()
            }
            
        }
    }
    
    
    // TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noIngredients {
            return 1
        } else {
            return ingredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredient", for: indexPath) as! ingredientTableCell
        
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = UIColor.white
        
        if loading {
            cell.ingredientName.text = "Loading Ingredients"
            cell.ingredientName.textColor = UIColor.darkGray
            cell.pathwaysTargeted.text = ""
            cell.toxicLabel.text = ""
            cell.toxicImageViewWidth.constant = CGFloat(0.0)
            cell.foodAdditiveImageViewWidth.constant = CGFloat(0.0)
            cell.ingredientNameTop.constant = CGFloat(25.0)
            cell.loadingIcon = FlowerSpinner(frame: CGRect(x: 210, y: 35, width: 6, height: 6))
            cell.loadingIcon.speed = 9
            cell.loadingIcon.backgroundColor = UIColor.white
            cell.loadingIcon.numberOfCircles = 12
            cell.loadingIcon.bezierHeight = 2
            cell.loadingIcon.bezierWidth = 7
            cell.loadingIcon.tintColor = UIColor.darkGray
            cell.addSubview(cell.loadingIcon)
        } else if noIngredients {
            cell.ingredientName.textColor = UIColor.black
            cell.loadingIcon.removeFromSuperview()
            cell.ingredientName.text = "No Recorded Ingredients"
            cell.pathwaysTargeted.text = ""
            cell.toxicLabel.text = ""
            cell.toxicImageViewWidth.constant = CGFloat(0.0)
            cell.foodAdditiveImageViewWidth.constant = CGFloat(0.0)
        } else {
            selectedBackground.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 249/255, alpha: 1)
            
            cell.ingredientName.textColor = UIColor.black
            cell.loadingIcon.removeFromSuperview()
            
            cell.ingredientName.text = ingredients[indexPath.row].ingredient_name
            
            cell.ingredientNameTop.constant = CGFloat(13.0)
            
            if ingredients[indexPath.row].t3db != "NA" {
                cell.toxinTargetIndicator.backgroundColor = UIColor(red: 44/255, green: 83/255, blue: 131/255, alpha: 1)
                cell.toxinTargetIndicator.layer.zPosition = 1000
                cell.toxinTargetIndicatorWidth.constant = CGFloat(18.0)
            }
            
            if ingredients[indexPath.row].pathway == "E" {
                cell.pathwaysTargeted.text = "Targets Estrogen Pathway"
                cell.pathwaysTargeted.textColor = UIColor.black
            } else if ingredients[indexPath.row].pathway == "T" {
                cell.pathwaysTargeted.text = "Targets Testosterone Pathway"
                cell.pathwaysTargeted.textColor = UIColor.black
            } else if ingredients[indexPath.row].pathway == "H" {
                cell.pathwaysTargeted.text = "Targets General Hormone Pathway"
                cell.pathwaysTargeted.textColor = UIColor.black
            } else {
                cell.pathwaysTargeted.text = "No Targeted Pathways"
            }
            
            if ingredients[indexPath.row].toxicity == 0 && ingredients[indexPath.row].eafus == "Y" {
                cell.toxicImageView.image = UIImage(named: "FoodAdditive")
                cell.toxicLabel.text = ""
                cell.foodAdditiveImageViewWidth.constant = CGFloat(0.0)
            } else if ingredients[indexPath.row].toxicity > 0 && ingredients[indexPath.row].eafus == "Y" {
                cell.toxicImageView.image = UIImage(named: "Toxic")
                cell.toxicLabel.text = ": \(ingredients[indexPath.row].toxicity)"
                cell.foodAdditiveImageView.image = UIImage(named: "FoodAdditive")
            } else if ingredients[indexPath.row].toxicity > 0 {
                cell.toxicImageView.image = UIImage(named: "Toxic")
                cell.toxicLabel.text = ": \(ingredients[indexPath.row].toxicity)"
                cell.foodAdditiveImageViewWidth.constant = CGFloat(0.0)
            } else {
                cell.toxicLabel.text = ""
                cell.toxicImageViewWidth.constant = CGFloat(0.0)
                cell.foodAdditiveImageViewWidth.constant = CGFloat(0.0)
            }
        }
        
        cell.selectedBackgroundView = selectedBackground
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !loading && !noIngredients {
            let ingredientPopup = self.storyboard?.instantiateViewController(withIdentifier: "IngredientPopupController") as! IngredientPopupController
            ingredientPopup.providesPresentationContextTransitionStyle = true
            ingredientPopup.definesPresentationContext = true
            ingredientPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            ingredientPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            ingredientPopup.ingredient = ingredients[indexPath.row]
            ingredientPopup.currTabBarController = self.tabBarController
            self.present(ingredientPopup, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

}
