//
//  InputFieldController.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 4/16/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import UIKit

// Input Field Controller Delegate Protocol
protocol InputFieldControllerDelegate: class {
    func inputFieldDoneEditing(text: String, textField: UITextField)
}


class InputFieldController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    // Properties
    var text = ""
    var labelText = ""
    var delegate: InputFieldControllerDelegate?
    var realTextField: UITextField!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets values equal to properties
        textField.delegate = self
        textField.text = text
        label.text = labelText
        textField.becomeFirstResponder()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Set translucent background for view
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Animate outer view for inputs when input field appears
        outerView.alpha = 0;
        outerView.frame.origin.y = outerView.frame.origin.y - 50
        UIView.animate(withDuration: 0.3) {
            self.outerView.alpha = 1.0;
            self.outerView.frame.origin.y = self.outerView.frame.origin.y + 50
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Sends fields to delegate and dismisses input field
        self.delegate?.inputFieldDoneEditing(text: textField.text!, textField: self.realTextField)
        self.dismiss(animated: true, completion: nil)

        return true
    }

    

}
