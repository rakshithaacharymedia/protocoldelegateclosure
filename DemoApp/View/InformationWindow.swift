//
//  InformationWindow.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit

class InformationWindow: UIView {
    @IBOutlet var view: UIView! 
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.lineBreakMode = .byCharWrapping
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.numberOfLines = 0;
            }
    }
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLabel: UILabel! {
        didSet {
             placeLabel.lineBreakMode = .byCharWrapping
             nameLabel.adjustsFontSizeToFitWidth = true
             placeLabel.numberOfLines = 0;
        }
    }
   @IBOutlet weak var directionButton: UIButton! {
    didSet {
           directionButton.layer.cornerRadius = 20
           directionButton.layer.borderWidth = 2
           directionButton.layer.borderColor = UIColor.white.cgColor
       }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        Bundle.main.loadNibNamed("InformationWindow", owner: self, options: nil)
        view.autoresizingMask = [.flexibleHeight]
        self.addSubview(self.view)
    }
  
    @IBAction func directionButtonTapped(_ sender: Any) {
    }
}
