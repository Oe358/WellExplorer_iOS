//
//  IngredientPopupController.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 6/17/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit

class ProteinPopupController: UIViewController {
    
    // Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var proteinNameLabel: UILabel!
    @IBOutlet weak var mechanismLabel: UILabel!
    @IBOutlet weak var geneNameLabel: UILabel!
    @IBOutlet weak var pathwayLabel: UILabel!
    @IBOutlet weak var proteinFunctionLabel: UILabel!
    @IBOutlet weak var uniprotButton: UIButton!
    
    
    // Properties
    var target: ProteinTarget = ProteinTarget(uniprot: "", protein_name: "", gene_name: "", pathway: "", mechanism: "", protein_function: "")
    var currTabBarController: UITabBarController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proteinNameLabel.text = target.protein_name
        
        if target.mechanism == "NA" {
            mechanismLabel.text = "Not Recorded"
        } else {
            mechanismLabel.text = target.mechanism
            mechanismLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        }
        
        if target.gene_name == "NA" {
            geneNameLabel.text = "Gene Name Not Recorded"
        } else {
            geneNameLabel.text = target.gene_name
            geneNameLabel.textColor = UIColor.black
        }
        
        if target.pathway == "NA" {
            pathwayLabel.text = "No Recorded Pathway"
        } else {
            pathwayLabel.text = target.pathway
            pathwayLabel.textColor = UIColor.black
        }
        
        if target.protein_function == "NA" {
            proteinFunctionLabel.text = "Not Recorded"
        } else {
            proteinFunctionLabel.text = target.protein_function
            proteinFunctionLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Set translucent background for view
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Animate outer view for inputs when input field appears
        outerView.alpha = 0;
        outerView.frame.origin.y = outerView.frame.origin.y - 100
        UIView.animate(withDuration: 0.3) {
            self.outerView.alpha = 1.0;
            self.outerView.frame.origin.y = self.outerView.frame.origin.y + 100
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Button Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func uniprotButtonTapped(_ sender: Any) {
        let uniprotPopup = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        uniprotPopup.providesPresentationContextTransitionStyle = true
        uniprotPopup.definesPresentationContext = true
        uniprotPopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        uniprotPopup.request = "https://www.uniprot.org/uniprot/\(target.uniprot)"
        self.present(uniprotPopup, animated: true, completion: nil)
    }
    
    @IBAction func searchWellsButtonTapped(_ sender: Any) {
        if target.gene_name == "NA" {
            let alert = UIAlertController(title: "No Gene Name", message: "There is no recorded gene name for this target, so it can not be searched for in Zip Searcher", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"No T3db Entry\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.currTabBarController?.selectedIndex = 0
            let navigationController = self.currTabBarController?.selectedViewController as! UINavigationController
            navigationController.viewControllers = [navigationController.viewControllers[0]]
            let viewController = navigationController.viewControllers[0] as! FirstViewController
            viewController.geneNameTextField.text = target.gene_name
            viewController.wellNameTextField.text = ""
            viewController.ingredientNameTextField.text = ""
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
    }
    
    
    
    
}
