//
//  CustomCollectionViewCell.swift
//  CollectionViewTest
//
//  Created by Maksym on 14.10.24.
//

import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        backgroundColor = isFocused ? .yellow : .white
    }
}
