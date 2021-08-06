//
//  ImageCollectionViewCell.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/28/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImage(itemImage: UIImage) {
        imageView.image = itemImage
    }
    
}
