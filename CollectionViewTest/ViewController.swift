//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Maksym on 14.10.24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    
    let sectionCount = 20
    let itemCount = 200
    
    var storedData = [[ClosedRange<Double>]]()
    var cachedData = [[ClosedRange<Double>]]()
    var contentSize = CGSize.zero
    
    var focusedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        generateStoredData()
        initCachedData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func generateStoredData() {
        contentSize.height = Double(sectionCount) * CustomCollectionViewLayout.cellHeight
        for _ in 0..<sectionCount {
            var sectionData = [ClosedRange<Double>]()
            var sectionLength = 0.0
            for _ in 0..<itemCount {
                let newItemLength = Double.random(in: 100...1000)
                sectionData.append(sectionLength...(sectionLength + newItemLength))
                sectionLength += newItemLength
            }
            storedData.append(sectionData)
            contentSize.width = max(contentSize.width, sectionLength)
        }
    }
    
    private func initCachedData() {
        for sectionData in storedData {
            cachedData.append([sectionData[itemCount / 2]])
        }
    }
    
    private func updateCachedData() {
        let activeRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size).insetBy(dx: -collectionView.frame.width / 2, dy: 0.0)
        collectionView.performBatchUpdates { [weak self] in
            guard let self else { return }
            
            for section in 0..<sectionCount {
                for itemData in storedData[section] {
                    let itemRect = CGRect(x: itemData.lowerBound,
                                          y: Double(section) * CustomCollectionViewLayout.cellHeight,
                                          width: itemData.upperBound - itemData.lowerBound,
                                          height: CustomCollectionViewLayout.cellHeight)
                    if itemRect.intersects(activeRect) && !cachedData[section].contains(itemData) {
                        collectionView.insertItems(at: [IndexPath(item: cachedData[section].count, section: section)])
                        cachedData[section].append(itemData)
                    }
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            focusedIndexPath = nextFocusedIndexPath
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        guard !indexPath.isEmpty else { return true }
        guard let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return false }
        
        if let focusedIndexPath = focusedIndexPath, let focusedLayoutAttributes = collectionView.layoutAttributesForItem(at: focusedIndexPath) {
            if focusedLayoutAttributes.frame.insetBy(dx: -1.0, dy: -1.0).intersects(layoutAttributes.frame) {
                return true
            }
        }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
            .insetBy(dx: CustomCollectionViewLayout.enoughtVisibleCellWidth, dy: 0.0)
        return visibleRect.intersects(layoutAttributes.frame)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            updateCachedData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCachedData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        cachedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cachedData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

