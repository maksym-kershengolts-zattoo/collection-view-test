//
//  CustomCollectionViewLayout.swift
//  CollectionViewTest
//
//  Created by Maksym on 14.10.24.
//

import UIKit

final class CustomCollectionViewLayout: UICollectionViewFlowLayout {
    static let cellHeight = 110.0
    static let enoughtVisibleCellWidth: CGFloat = 60.0

    var contentSize = CGSize.zero
    
    private var cellAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        cellAttributes = [:]
        
        guard let collectionView, let dataSource = (collectionView.dataSource as? ViewController) else { return }
        
        contentSize = dataSource.contentSize
        
        for section in 0..<collectionView.numberOfSections {
            let yPosition = Double(section) * CustomCollectionViewLayout.cellHeight
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let itemData = dataSource.cachedData[section][item]
                let cellIndexPath = IndexPath(item: item, section: section)
                let currentCellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                currentCellAttributes.frame = CGRect(x: itemData.lowerBound,
                                                     y: yPosition,
                                                     width: itemData.upperBound - itemData.lowerBound,
                                                     height: CustomCollectionViewLayout.cellHeight)
                cellAttributes[cellIndexPath] = currentCellAttributes
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        for currentCellAttributes in cellAttributes.values {
            if rect.intersects(currentCellAttributes.frame) {
                attributesInRect.append(currentCellAttributes)
            }
        }
        return attributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes[indexPath]
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView, let focusedCell = UIScreen.main.focusedView as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: focusedCell), let attribute = cellAttributes[indexPath] else { return proposedContentOffset }
            
        switch isCellEnoughVisibleWithoutScrolling(cell: focusedCell) {
        case (true, true):
            return collectionView.contentOffset
        case (true, false):
            let xPosition = attribute.frame.origin.x
            if collectionView.contentOffset.x > xPosition {
                let prevPageOffset = collectionView.contentOffset.x - collectionView.bounds.width
                return CGPoint(x: min(xPosition, prevPageOffset), y: collectionView.contentOffset.y)
            } else {
                return CGPoint(x: xPosition, y: collectionView.contentOffset.y)
            }
        case (false, true):
            let yPosition = attribute.frame.origin.y
            if collectionView.contentOffset.y > proposedContentOffset.y {
                return CGPoint(x: collectionView.contentOffset.x, y: max(0, (yPosition - CGFloat(CustomCollectionViewLayout.cellHeight * 9))))
            } else {
                let bottomMargin = collectionView.bounds.height.truncatingRemainder(dividingBy: CGFloat(CustomCollectionViewLayout.cellHeight))
                return CGPoint(x: collectionView.contentOffset.x, y: min(collectionView.contentSize.height - collectionView.bounds.height + bottomMargin, yPosition))
            }
        case (false, false):
            let xPosition = attribute.frame.origin.x
            let yPosition = attribute.frame.origin.y
            return CGPoint(x: xPosition, y: yPosition)
        }
    }
    
    private func isCellEnoughVisibleWithoutScrolling(cell: UICollectionViewCell) -> (vertically: Bool, horizontally: Bool) {
        guard let collectionView, let indexPath = collectionView.indexPath(for: cell), let cellFrame = cellAttributes[indexPath]?.frame else {
            return (vertically: false, horizontally: false)
        }

        let verticallyVisible = cellFrame.origin.y >= collectionView.contentOffset.y && cellFrame.origin.y + cellFrame.height <= collectionView.contentOffset.y + collectionView.frame.height
        let horizontallyVisible = cellFrame.origin.x + cellFrame.width >= collectionView.contentOffset.x + CustomCollectionViewLayout.enoughtVisibleCellWidth && cellFrame.origin.x <= collectionView.contentOffset.x + collectionView.frame.width - CustomCollectionViewLayout.enoughtVisibleCellWidth
        
        return (vertically: verticallyVisible, horizontally: horizontallyVisible)
    }
}
