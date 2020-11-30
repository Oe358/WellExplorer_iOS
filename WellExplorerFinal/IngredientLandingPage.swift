//
//  IngredientLandingPage.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 6/29/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit

class proteinTargetTableCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var proteinName: UILabel!
    @IBOutlet weak var geneName: UILabel!
    @IBOutlet weak var pathwayLabel: UILabel!
    
    
    // Properties
    var loadingIcon = FlowerSpinner()
}

class IngredientLandingPage: UIViewController, UITableViewDelegate, UITableViewDataSource, Downloadable {
    

    // Outlets
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var casNumberLabel: UILabel!
    @IBOutlet weak var toxicityLabel: UILabel!
    @IBOutlet weak var foodAdditiveLabel: UILabel!
    @IBOutlet weak var pathwaysLabel: UILabel!
    @IBOutlet weak var proteinTargetsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var proteinTargetsTableView: UITableView!
    @IBOutlet weak var t3dbButton: UIButton!
    
    // Properties
    var model = WellModel()
    var ingredient: IngredientShort = IngredientShort(ingredient_name: "", cas: "", pathway: "", toxicity: 0, eafus: "", t3db: "", protein_targets: "")
    var proteinTargets: [ProteinTarget] = []
    var noResults = true
    var loading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting delegates to self
        model.delegate = self
        self.proteinTargetsTableView.delegate = self
        self.proteinTargetsTableView.dataSource = self
        self.proteinTargetsTableViewHeight.constant = CGFloat(125.0)
        
        // Setting label texts using ingredient data
        noResults = !(ingredient.protein_targets == "Y")
        ingredientNameLabel.text = ingredient.ingredient_name
        casNumberLabel.text = "CAS: \(ingredient.cas)"
        if ingredient.toxicity > 0 {
            toxicityLabel.text = "\(ingredient.toxicity)"
        } else {
            toxicityLabel.text = "Not Toxic"
        }
        if ingredient.eafus == "Y" {
            foodAdditiveLabel.text = "Yes"
        } else {
            foodAdditiveLabel.text = "No"
        }
        if ingredient.pathway == "H" {
            pathwaysLabel.text = "General Hormone"
        } else if ingredient.pathway == "E" {
            pathwaysLabel.text = "Estrogen"
        } else if ingredient.pathway == "T" {
            pathwaysLabel.text = "Testosterone"
        }
        if ingredient.t3db == "NA" {
            t3dbButton.setTitleColor(UIColor.black, for: .normal)
            t3dbButton.setTitle("Not Registered in T3DB", for: .normal)
        }
        
        dataSetup()
    }
    
    func dataSetup() {
        
        let ingredientParams = ["t3db_id": ingredient.t3db, "response_type": "protein_targets"] as [String: Any]
        self.model.downloadWells(parameters: ingredientParams, url: URLServices.wells)
        
    }

    
    func didReceiveData(data: Any) {
        
        DispatchQueue.main.async {
            
            if data is [ProteinTarget] {
                
                
                if (data as! [ProteinTarget]).count > 0 {
                    self.proteinTargets = data as! [ProteinTarget]
                    self.proteinTargetsTableViewHeight.constant = CGFloat(45.0 + Double(self.proteinTargets.count) * 80.0)
                }
                
                self.loading = false
                
                self.proteinTargetsTableView.reloadData()
            }
            
        }
        
    }
    
    // Actions
    @IBAction func t3dbButtonTapped(_ sender: Any) {
        if ingredient.t3db == "NA" {
            let alert = UIAlertController(title: "No T3DB Entry", message: "There is no entry in the T3DB database for this ingredient", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"No T3db Entry\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let t3dbPopup = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            t3dbPopup.providesPresentationContextTransitionStyle = true
            t3dbPopup.definesPresentationContext = true
            t3dbPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            t3dbPopup.request = "http://www.t3db.ca/toxins/\(ingredient.t3db)"
            self.present(t3dbPopup, animated: true, completion: nil)
        }
    }
    
    @IBAction func searchWellsButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        let navigationController = self.tabBarController?.selectedViewController as! UINavigationController
        navigationController.viewControllers = [navigationController.viewControllers[0]]
        let viewController = navigationController.viewControllers[0] as! FirstViewController
        viewController.ingredientNameTextField.text = ingredient.ingredient_name
        viewController.wellNameTextField.text = ""
        viewController.geneNameTextField.text = ""
        viewController.hormoneOn = false
        viewController.estrogenOn = false
        viewController.testosteroneOn = false
        viewController.pathwaysButton.setTitleColor(UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1), for: .normal)
        viewController.pathwaysButton.setTitle("Genes and Pathways Affected", for: .normal)
        viewController.onlyToxicSwitch.setOn(false, animated: false)
        viewController.inputsView.shadowRadius = 4
        viewController.inputsViewHeight.constant = 460
        viewController.inputsViewLeading.constant = 22
        viewController.optionsButton.setTitle("Hide Search Options", for: .normal)
        viewController.expandedInputsView.isHidden = false
        viewController.inputsView.addConstraint(viewController.locateWellsTop)
        viewController.expanded = true
        viewController.zipTextField.becomeFirstResponder()
    }
    
    
    
    // Table View methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noResults {
            return 1
        } else {
            return proteinTargets.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proteinTarget", for: indexPath) as! proteinTargetTableCell
        
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = UIColor.white
        
        if loading {
            cell.proteinName.text = "Loading Ingredients"
            cell.proteinName.textColor = UIColor.darkGray
            cell.geneName.text = ""
            cell.pathwayLabel.text = ""
            cell.loadingIcon = FlowerSpinner(frame: CGRect(x: 210, y: 35, width: 6, height: 6))
            cell.loadingIcon.speed = 9
            cell.loadingIcon.backgroundColor = UIColor.white
            cell.loadingIcon.numberOfCircles = 12
            cell.loadingIcon.bezierHeight = 2
            cell.loadingIcon.bezierWidth = 7
            cell.loadingIcon.tintColor = UIColor.darkGray
            cell.addSubview(cell.loadingIcon)
        } else if noResults {
            cell.proteinName.textColor = UIColor.black
            cell.geneName.text = ""
            cell.pathwayLabel.text = ""
            cell.loadingIcon.removeFromSuperview()
            cell.proteinName.text = "No Recorded Protein Targets"
        } else {
            selectedBackground.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 249/255, alpha: 1)
            
            cell.proteinName.textColor = UIColor.black
            cell.loadingIcon.removeFromSuperview()
            
            cell.proteinName.text = proteinTargets[indexPath.row].protein_name
            
            if proteinTargets[indexPath.row].gene_name == "NA" {
                cell.geneName.text = ""
            } else {
                cell.geneName.text = proteinTargets[indexPath.row].gene_name
            }
            
            if proteinTargets[indexPath.row].pathway != "NA" {
                cell.pathwayLabel.text = proteinTargets[indexPath.row].pathway
                cell.pathwayLabel.textColor = UIColor.black
            } else {
                cell.pathwayLabel.text = "No Recorded Pathway"
            }
            

        }
        
        cell.selectedBackgroundView = selectedBackground
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !loading && !noResults {
            let targetPopup = self.storyboard?.instantiateViewController(withIdentifier: "ProteinPopupController") as! ProteinPopupController
            targetPopup.providesPresentationContextTransitionStyle = true
            targetPopup.definesPresentationContext = true
            targetPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            targetPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            targetPopup.target = proteinTargets[indexPath.row]
            targetPopup.currTabBarController = self.tabBarController
            self.present(targetPopup, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

}
