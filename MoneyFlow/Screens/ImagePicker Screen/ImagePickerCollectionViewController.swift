//
//  ImagePickerCollectionViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 29/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

protocol ImagePickerCollectionViewControllerDelegate: class {
    var loadedPhotos: [UIImage] { get set }
}

class ImagePickerCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let photoCellReuseIdentifier = "photoCollectiovViewCell"
    private var allPhotos: PHFetchResult<PHAsset>? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        }
    }
    
    private var selectedPhotos = [Int: UIImage]()
    weak var delegate: ImagePickerCollectionViewControllerDelegate!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        delegate?.loadedPhotos += [UIImage](selectedPhotos.values)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9321933125, green: 0.9321933125, blue: 0.9321933125, alpha: 1)
        collectionView.allowsMultipleSelection = true
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.sectionInset = UIEdgeInsets(top: 1, left: 2.5, bottom: 0, right: 2.5)

        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                if self != nil {
                    self!.allPhotos = PHAsset.fetchAssets(with: .image, options: self!.fetchOptions())
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
    private func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 200
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }
    
    private func loadImage(at index: Int, contentMode: PHImageContentMode, with size: CGSize) -> UIImage? {
        guard allPhotos != nil else { return nil }
        
        let manager = PHImageManager.default()
        var image: UIImage? = nil
        manager.requestImage(for: allPhotos!.object(at: index), targetSize: size, contentMode: contentMode, options: requestOptions()) { img, err  in
            guard let img = img else { return }
            image = img
        }
        return image
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        let asset = allPhotos?.object(at: indexPath.row)
        cell.imageView.fetchImage(asset: asset!, contentMode: .aspectFit, targetSize: cell.bounds.size)
//        cell.imageView.image = UIImage(named: "sberbank_ops_screen")!
        
        
        if selectedPhotos[indexPath.row] != nil {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        } else {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenAspectRatio = screenSize.width / screenSize.height
        let width = (collectionView.bounds.width - 9) / 3.0
        let height = width / screenAspectRatio
        let size = CGSize(width: width, height: width)
        return size
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        selectedPhotos[indexPath.row] = loadImage(at: indexPath.row, contentMode: .default, with: UIScreen.main.bounds.size)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        selectedPhotos[indexPath.row] = nil
    }



}
