//
//  ManagingAccountsCollectionViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AccountsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var listTypeRawValues: [String] {
        return AccountsViewController.ListType.allRawValues
    }
    
    private var listTypes: [AccountsViewController.ListType] {
        return AccountsViewController.ListType.all
    }
    
    private var currenciesCount: Int {
        return presenter.currencies.count == 1 ? 0 : presenter.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currenciesCount + listTypeRawValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currencyCollectionViewCellIdentifier, for: indexPath) as! CurrencyCollectionViewCell
        if indexPath.row < currenciesCount {
            cell.label.text = presenter.currencySignes[indexPath.row]
            if mainCurrency == presenter.currencies[indexPath.row] {
                cell.label.textColor = .white
            } else {
                cell.label.textColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
            }
        } else {
            let index = indexPath.row - currenciesCount
            cell.label.text = listTypeRawValues[index]
            if listType == listTypes[index] {
                cell.label.textColor = .white
            } else {
                cell.label.textColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
            }
        }
        return cell
    }
    
    // set size of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        if indexPath.row < currenciesCount {
            label.text = "___" + presenter.currencySignes[indexPath.row] + "___"
        } else {
            let index = indexPath.row - currenciesCount
            label.text = "__" + listTypeRawValues[index] + "__"
        }
        label.sizeToFit()
        
        let widthOfCell = label.intrinsicContentSize.width
        let heightOfCell = label.intrinsicContentSize.height * 2
        
        return CGSize(width: widthOfCell, height: heightOfCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < currenciesCount {
            guard mainCurrency != presenter.currencies[indexPath.row] else { return }
            mainCurrency = presenter.currencies[indexPath.row]
        } else {
            let index = indexPath.row - currenciesCount
            guard listType != listTypes[index] else { return }
            listType = listTypes[index]
        }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        updateData()
        collectionView.reloadData()
    }
    
}

