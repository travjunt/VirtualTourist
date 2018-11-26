//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Photo Album CollectionViewCell

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
	
	// MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            imageView.alpha = isSelected ? 0.5 : 1.0
        }
    }
}
