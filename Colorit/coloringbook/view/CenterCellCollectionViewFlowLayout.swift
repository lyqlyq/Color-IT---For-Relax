//
//  CenterCellCollectionViewFlowLayout.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/23/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let collectionView = self.collectionView {
            
            let collectionViewBounds = collectionView.bounds
            let halfWidth = collectionViewBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: collectionViewBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                
                for attributes in attributesForVisibleCells {
                    // Skip comparison with non-cell items (headers and footers)
                    if attributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                        continue
                    }
                    
                    if let candAttrs = candidateAttributes {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        
                        if velocity.x < 0 {
                            continue
                        } else if velocity.x > 0 {
                            candidateAttributes = attributes
                        } else if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes
                        }
                        
                    } else { // First time in the loop
                        candidateAttributes = attributes;
                        continue;
                    }
                }
                return CGPoint(x : candidateAttributes!.center.x - halfWidth, y : proposedContentOffset.y);
            }
        }
        // fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if self.collectionView != nil {
            return targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: CGPoint.zero)
        }
        // fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}



