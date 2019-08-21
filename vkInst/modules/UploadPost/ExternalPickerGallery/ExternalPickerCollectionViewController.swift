//
//  ExternalPickerCollectionViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

protocol ExternalPickerCollectionViewControllerProtocol: class {
    func fetchComplete(fetchResult: PHFetchResult<PHAsset>)
}

class ExternalPickerCollectionViewController: UICollectionViewController {
    
    private struct Constants {
        static let pickerCollectionViewCellReuseIdentifier = "externalGalleryCell"
        static let photosSortDescriptorKey = "creationDate"
        static let collectionViewInitFatalErrorDescription = "Unexpected cell in collection view"
    }
    
    var selectedItems = [Int]()
    
    var fetchResult: PHFetchResult<PHAsset>!
    var availableWidth: CGFloat = 0
    
    var presenter: ExternalPickerPresenter?
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    fileprivate var thumbnailSize: CGSize!
    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustCollectionViewItemSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineItemSize()
        checkSelectedImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.pickerCollectionViewCellReuseIdentifier, for: indexPath) as? ExternalGalleryCollectionViewCell
            else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.configureCell(with: asset, itemSize: thumbnailSize)
        if let k = selectedItems.firstIndex(of: indexPath.item) {
            cell.setSerialNumber(number: k + 1)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        checkSelectedImages()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? ExternalGalleryCollectionViewCell else { return }
        selectedItems.append(indexPath.item)
        item.setSerialNumber(number: selectedItems.count)
        if selectedItems.count > 10 {
            selectedItems.remove(at: 0)
            collectionView.reloadData()
        }
        checkSelectedImages()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? ExternalGalleryCollectionViewCell else { return }
        if let i = selectedItems.firstIndex(of: indexPath.item) {
            selectedItems.remove(at: i)
        }
        item.deselectSerialNumber()
        collectionView.reloadData()
    }
}

extension ExternalPickerCollectionViewController: ExternalPickerCollectionViewControllerProtocol {
    func fetchComplete(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
        collectionView.reloadData()
    }
}

private extension ExternalPickerCollectionViewController {
    func configureUI() {
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView.allowsSelection = true
        self.collectionView.allowsMultipleSelection = true
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.toolbar.barTintColor = UIColor.black
        let addSelectedImages = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addSelectedImagesButtonPressed))
        navigationItem.rightBarButtonItem = addSelectedImages
    }
    
    func checkSelectedImages() {
        if collectionView.indexPathsForSelectedItems?.isEmpty == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func adjustCollectionViewItemSize() {
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    func determineItemSize() {
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    @objc func addSelectedImagesButtonPressed() {
        var selectedAssets = [PHAsset]()
        for selectedItem in selectedItems {
            let asset = fetchResult.object(at: selectedItem)
            selectedAssets.append(asset)
        }
        presenter?.pickDidEnded(assets: selectedAssets)
    }
}
