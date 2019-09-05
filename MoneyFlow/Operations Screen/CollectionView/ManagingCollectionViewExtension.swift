//
//  ManagingCollectionViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension OperationsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var arrayOfAllFilterUnits: [String] {
        return ["Все"] + OperationPresenter.allCurrencies + OperationPresenter.allAccounts + OperationPresenter.allCategories + OperationPresenter.allContacts
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfAllFilterUnits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCollectionViewCellIdentifier, for: indexPath) as! FilterCollectionViewCell
        cell.label.text = arrayOfAllFilterUnits[indexPath.row]
        
        if appliedFilterCells.contains(indexPath) {
            cell.isApplied = true
        } else {
            cell.isApplied = false
        }
        return cell
    }
    
    // set size of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = "!    " + arrayOfAllFilterUnits[indexPath.row] + "    !"
        label.sizeToFit()
        
        let widthOfCell = label.intrinsicContentSize.width
        let heightOfCell = label.intrinsicContentSize.height * 2
        
        return CGSize(width: widthOfCell, height: heightOfCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FilterCollectionViewCell
        switch cell.isApplied {
            
        case false where indexPath.row == 0:
            generateFeedbackFor(.selectAll)
            appliedFilterCells.removeAll()
            cell.isApplied = true
            appliedFilterCells.append(indexPath)
            collectionView.reloadData()
            
        case false:
            cell.isApplied = true
            
            if appliedFilterCells.count == 1 && appliedFilterCells.first!.row == 0 {
                appliedFilterCells.removeAll()
            }
            
            appliedFilterCells.append(indexPath)
            generateFeedbackFor(.selectUnit)
            collectionView.reloadData()
            
        case true where indexPath.row == 0:
            generateFeedbackFor(.error)
            break
            
        case true:
            cell.isApplied = false
            appliedFilterCells = appliedFilterCells.filter { $0 != indexPath }
            if appliedFilterCells.isEmpty {
                generateFeedbackFor(.deselectLast)
                let firstCellIndexPath = IndexPath(row: 0, section: 0)
                appliedFilterCells.append(firstCellIndexPath)
                collectionView.reloadData()
            } else {
                generateFeedbackFor(.deselectUnit)
            }
        }
        
    }
    
    
    private func generateFeedbackFor(_ event: FeedbackEvent) {
        switch event {
        case .selectUnit:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .deselectUnit:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .deselectLast:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .selectAll:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .error:
            break
        }
    }
    
    private enum FeedbackEvent {
        case selectUnit, deselectUnit, deselectLast, selectAll, error
    }
    
}


