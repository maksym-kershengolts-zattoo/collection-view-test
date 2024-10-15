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
    
    var data: [[Double]] = []
    
    var focusedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0..<sectionCount {
            data.append([])
        }
        generateData()
    }
    
    private func generateData() {
        collectionView.performBatchUpdates { [weak self] in
            guard let self else { return }
            for section in 0..<sectionCount {
                var sectionLength = data[section].reduce(0, +)
                while sectionLength < collectionView.contentOffset.x + 1.5 * collectionView.frame.width {
                    let newValue = Double.random(in: 100...1000)
                    collectionView.insertItems(at: [IndexPath(item: data[section].count, section: section)])
                    data[section].append(newValue)
                    sectionLength += newValue
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
            generateData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        generateData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

