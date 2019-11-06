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

extension DataSourceLoadManagerDelegate {
    var downloadProgress: Double {
        get { return 0 }
        set{}
    }
    var uploadProgress: Double {
        get{ return 0 }
        set{}
    }
    func downloadComplete(with error: Error?) {}
    func uploadComplete(with error: Error?) {}
    
}

class DataSourceLoadManager: CloudSettingsDataSourceDelegate, CloudDataSourceDelegate, CloudIDGeneratorDelegate {
    
    static let shared = DataSourceLoadManager()
    
    private var source = MainData.source as? CloudOperationDataSource
    private var settings = MainData.settings as? CloudSettingsDataSource
    private var generator = MainGenerator.generator as? CloudIDGenerator
    
    weak var delegate: DataSourceLoadManagerDelegate!
    
    var downloadProgress: Double = 0 { didSet { if downloadProgress != 0 { delegate?.downloadProgress = downloadProgress } } }
    var uploadProgress: Double = 0 { didSet { if uploadProgress != 0 { delegate?.uploadProgress = uploadProgress } } }
    
    var isDownloadComplete: Bool = false { didSet { if isDownloadComplete { print("Download completed") } } }
    var isUploadComplete: Bool = false { didSet { if isUploadComplete { print("Upload completed") } } }
    
    
    // MARK: Downloads
    
    /// Do NOT call this method
    func downloadComplete(with error: Error?) {
        print("Operations downloaded: \(error?.localizedDescription ?? "successfully")")
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
                if !isDownloadComplete { isDownloadComplete = true }
            }
        }
    }
    /// Do NOT call this method
    func settingsDownloadComplete(with error: Error?) {
        print("Settings downloaded: \(error?.localizedDescription ?? "successfully")")
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
                if !isDownloadComplete { isDownloadComplete = true }
            }
        }
    }
    /// Do NOT call this method
    func generatorDownloadComplete(with error: Error?) {
        print("Generator downloaded: \(error?.localizedDescription ?? "successfully")")
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
                if !isDownloadComplete { isDownloadComplete = true }
            }
        }
    }
    
    
    // MARK: Uploads
    
    /// Do NOT call this method
    func uploadComplete(with error: Error?) {
        print("Operations uploaded: \(error?.localizedDescription ?? "successfully")")
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
        delegate?.uploadComplete(with: nil)
        if !isUploadComplete { isUploadComplete = true }
    }
    
    // don't use it yet
    /// Do NOT call this method
    func settingsUploadComplete(with error: Error?) {
        print("Settings uploaded: \(error?.localizedDescription ?? "successfully")")
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
    }
    
    //don't us it. We don't care about id uploading
    /// Do NOT call this method
    func generatorUploadComplete(with error: Error?) {
        print("Generator uploaded: \(error?.localizedDescription ?? "successfully")")
        guard error == nil else {
            if !isUploadComplete {
                delegate?.uploadComplete(with: error)
                isUploadComplete = true
            }
            return
        }
    }
    
    
    // MARK: Resetting and init
    
    func updateData() {
        newSession()
        source?.updateData()
        settings?.updateData()
    }
    
    func cancelLoading() {
        source?.cancelLoading()
        settings?.cancelLoading()
        generator?.cancelLoading()
    }
    
    func newSession() {
        downloadProgress = 0
        uploadProgress = 0
        isDownloadComplete = false
        isUploadComplete = false
        print("New load session created")
    }
    
    private init() {
        source?.delegate = self
        settings?.delegate = self
        generator?.delegate = self
        
        isDownloadComplete = source?.isDownloadComplete ?? true
            && settings?.isDownloadComplete ?? true
            && generator?.isDownloadComplete ?? true
    }
    
}
