//
//  PhotoCell.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        
        didSet {
            
            self.layer.cornerRadius = self.isSelected ? 20.0 : 0.0
            
        }
    }
}
