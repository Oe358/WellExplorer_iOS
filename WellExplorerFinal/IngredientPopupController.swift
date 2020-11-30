//
//  IngredientPopupController.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 6/17/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    // Outlets
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backNavigationButton: UIButton!
    @IBOutlet weak var forwardNavigationButton: UIButton!
    
    // Properties
    var request: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myUrl = URL(string: request)
        let myRequest = URLRequest(url: myUrl!)
        webView.load(myRequest)
                
        backNavigationButton.isEnabled = false
        forwardNavigationButton.isEnabled = false
        
        webView.borderWidth = CGFloat(1.0)
        webView.borderColor = UIColor.lightGray
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressView.setProgress(0.0, animated: false)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            backNavigationButton.isEnabled = webView.canGoBack
            forwardNavigationButton.isEnabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            print("Estimated Progress: \(webView.estimatedProgress)")
            if webView.estimatedProgress == 1 {
                progressView.isHidden = true
                progressView.setProgress(0.0, animated: false)
            } else {
                progressView.isHidden = false
                progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backNavigationTapped(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardNavigationTapped(_ sender: Any) {
        webView.goForward()
    }
}

class IngredientPopupController: UIViewController {
    
    // Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var supplierLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var casNumberLabel: UILabel!
    @IBOutlet weak var toxicityLabel: UILabel!
    @IBOutlet weak var foodAdditiveLabel: UILabel!
    @IBOutlet weak var pathwaysLabel: UILabel!
    @IBOutlet weak var t3dbButton: UIButton!
    @IBOutlet weak var proteinTargetsButton: UIButton!
    
    // Properties
    var ingredient: Ingredient = Ingredient(ingredient_name: "", cas: "", supplier: "", purpose: "", pathway: "", toxicity: 0, eafus: "", t3db: "", protein_targets: "")
    var currTabBarController: UITabBarController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientNameLabel.text = ingredient.ingredient_name
        supplierLabel.text = "Supplier: \(ingredient.supplier)"
        purposeLabel.text = "Purpose: \(ingredient.purpose)"
        casNumberLabel.text = "CAS: \(ingredient.cas)"
        
        if ingredient.toxicity == 0 {
            toxicityLabel.text = "Not Toxic"
        } else {
            toxicityLabel.text = "Toxicity Ranking: \(ingredient.toxicity)"
            toxicityLabel.textColor = UIColor.black
        }
        
        if ingredient.eafus == "Y" {
            foodAdditiveLabel.text = "Food Additive"
            foodAdditiveLabel.textColor = UIColor.black
        } else {
            foodAdditiveLabel.text = "Not Known Food Additive"
        }
        
        if ingredient.pathway == "E" {
            pathwaysLabel.text = "Targets Estrogen Pathway"
            pathwaysLabel.textColor = UIColor.black
        } else if ingredient.pathway == "T" {
            pathwaysLabel.text = "Targets Testosterone Pathway"
            pathwaysLabel.textColor = UIColor.black
        } else if ingredient.pathway == "H" {
            pathwaysLabel.text = "Targets General Hormone Pathway"
            pathwaysLabel.textColor = UIColor.black
        } else {
            pathwaysLabel.text = "No Targeted Pathways"
        }
        
        if ingredient.t3db == "NA" {
            t3dbButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            t3dbButton.setTitle("See T3DB Entry", for: .normal)
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
    @IBAction func backButttonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func t3dbButtonTapped(_ sender: UIButton) {
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
    
    @IBAction func proteinTargetsButtonTapped(_ sender: UIButton) {
        self.currTabBarController?.selectedIndex = 1
        let ingredientLandingPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IngredientLandingPage") as! IngredientLandingPage
        ingredientLandingPage.ingredient = IngredientShort(ingredient_name: ingredient.ingredient_name, cas: ingredient.cas, pathway: ingredient.pathway, toxicity: ingredient.toxicity, eafus: ingredient.eafus, t3db: ingredient.t3db, protein_targets: ingredient.protein_targets)
        let navigationController = self.currTabBarController?.selectedViewController as! UINavigationController
        navigationController.viewControllers = [navigationController.viewControllers[0]]
        navigationController.pushViewController(ingredientLandingPage, animated: false)
    }
    
    
    
}
