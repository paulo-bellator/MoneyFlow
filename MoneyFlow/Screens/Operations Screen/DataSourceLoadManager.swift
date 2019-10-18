//
//  DataSourceLoadManager.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 18/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol DataSourceLoadManagerDelegate: class {
    var downloadProgress: Double { get set }
    var uploadProgress: Double { get set }
    func downloadComplete(with error: Error?)
    func uploadComplete(with error: Error?)
}

class DataSourceLoadManager: CloudSettingsDataSourceDelegate, CloudDataSourceDelegate, CloudIDGeneratorDelegate {
    
    private let source = MainData.source as? CloudOperationDataSource
    private let settings = MainData.settings as? CloudSettingsDataSource
    private let generator = MainGenerator.generator as? CloudIDGenerator
    
    weak var delegate: DataSourceLoadManagerDelegate!
    
    var downloadProgress: Double = 0 { didSet { delegate?.downloadProgress = downloadProgress } }
    var uploadProgress: Double = 0 { didSet { delegate?.uploadProgress = uploadProgress } }
    
    var isDownloadComplete: Bool = false
    var isUploadComplete: Bool = false
    
    func downloadComplete(with error: Error?) {
        guard error == nil else {
            if !isDownloadComplete {
                delegate?.downloadComplete(with: error)
                isDownloadComplete = true
            }
            return
        }
        if settings?.isDownloadComplete ?? true {
            if generator?.isDownloadComplete ?? true {
                delegate?.downloadComplete(with: nil)
            }
        }
    }
    func settingsDownloadComplete(with error: Error?) {
        guard error == nil else {
            if !isDownloadComplete {
                delegate?.downloadComplete(with: error)
                isDownloadComplete = true
            }
            return
        }
        if source?.isDownloadComplete ?? true {
            if generator?.isDownloadComplete ?? true {
                delegate?.downloadComplete(with: nil)
            }
        }
    }
    func generatorDownloadComplete(with error: Error?) {
        guard error == nil else {
            if !isDownloadComplete {
                delegate?.downloadComplete(with: error)
                isDownloadComplete = true
            }
            return
        }
        if settings?.isDownloadComplete ?? true {
            if source?.isDownloadComplete ?? true {
                delegate?.downloadComplete(with: nil)
            }
        }
    }
    
    
    
    
    func uploadComplete(with error: Error?) {
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
    }
    func settingsUploadComplete(with error: Error?) {
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
    }
    func generatorUploadComplete(with error: Error?) {
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
    }
    
    
    
    
    
    
    func newSession() {
        downloadProgress = 0
        uploadProgress = 0
        isDownloadComplete = false
        isUploadComplete = false
    }
    
}
