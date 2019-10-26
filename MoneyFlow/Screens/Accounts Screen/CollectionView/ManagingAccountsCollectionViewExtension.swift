//
//  ManagingAccountsCollectionViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AccountsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currencyCollectionViewCellIdentifier, for: indexPath) as! CurrencyCollectionViewCell
        cell.label.text = presenter.currencySignes[indexPath.row]
        if mainCurrency == presenter.currencies[indexPath.row] {
            cell.label.textColor = .white
        } else {
            cell.label.textColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        }
        return cell
    }
    
    // set size of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = "_____" + presenter.currencySignes[indexPath.row] + "_____"
        label.sizeToFit()
        
        let widthOfCell = label.intrinsicContentSize.width
        let heightOfCell = label.intrinsicContentSize.height * 2
        
        return CGSize(width: widthOfCell, height: heightOfCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mainCurrency != presenter.currencies[indexPath.row] {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            mainCurrency = presenter.currencies[indexPath.row]
            updateData()
            collectionView.reloadData()
        }
    }

}
