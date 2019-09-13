//
//  UploadPostViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

protocol UploadPostViewControllerProtocol: class {
    func pickComplete(assets: [PHAsset])
    //func startUploadPhoto(data: Data, fileName: String, progress: @escaping Update, completion: @escaping PostUploadCompletion)
    //func photoDidUpload(id: Int)
    //func cancelUpload(id: Int?, fileName: String, completion: @escaping CancelCompletion)
    func uploadComplete(at index: Int, id: Int)
    func setProgress(at index: Int, progress: Float)
    func deleteCell(at index: Int)
}

class UploadPostViewController: UIViewController {
    
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endSelectPhotosButton: UIButton!
    @IBOutlet weak var photoPickerCollectionView: UICollectionView!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var photoPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var openGalleryButton: UIButton!
    @IBOutlet weak var selectedImagesCollectionView: UICollectionView!
    @IBOutlet weak var pickerCollectionView: UICollectionView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var openGalleryView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textViewContainer: UIView!
    
    
    
    private struct Constants {
        static let pickerCollectionViewCellReuseIdentifier = "galleryPhotoCell"
        static let selectedImageCollectionViewCellReuseIdentifier = "uploadPostSelectedCell"
        static let openGalleryCollectionViewCell = "openGalleryCell"
        static let collectionViewInitFatalErrorDescription = "Unexpected cell in collection view"
        static let textViewPlaceholder = "What's new?"
        static let internetConnectionErrorMessage = "Internet connection are not available"
        static let creationDateSortDescriptorKey = "creationDate"
        static let defaultPickerCollectionViewItemsCount = 31
        static let textViewFontSize = CGFloat(22)
        static let defaultToolbarHeight = CGFloat(50)
        static let pickerViewAnimationDuration = 0.3
        static let pickerViewConstraintMultiplier = CGFloat(150)
    }
    
    var flowLayout = photoPickerFlowLayout()
    var photosFromGallery: PHFetchResult<PHAsset>?
    var presenter: UploadPostPresenterProtocol?
    var selectedAssets = [PHAsset]()
    var itemToUploadCount = 0
    var selectedItems = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = true
        if pickerCollectionView.alpha == 1.0 {
            hidePickerView()
        }
        configurePresentation()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            presenter?.invalidateSession()
        }
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        presentPickerView()
    }
    
    @IBAction func closePickerButtonPressed(_ sender: UIButton) {
        hidePickerView()
        var assets = [PHAsset]()
        for item in selectedItems {
            guard let asset = photosFromGallery?.object(at: item) else { return }
            assets.append(asset)
        }
        pickComplete(assets: assets)
        selectedItems.removeAll()
        photoPickerCollectionView.reloadData()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hidePickerView()
        selectedItems.removeAll()
        pickerCollectionView.reloadData()
    }
    
    @IBAction func openGalleryButton(_ sender: UIButton) {
        presenter?.presentGallery()
    }
}

extension UploadPostViewController: UploadPostViewControllerProtocol {
    func deleteCell(at index: Int) {
        selectedImagesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func pickComplete(assets: [PHAsset]) {
        presenter?.updateDataSource(assets: assets)
        selectedImagesCollectionView.reloadData()
    }
    
    func uploadComplete(at index: Int, id: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard selectedImagesCollectionView.indexPathsForVisibleItems.contains(indexPath),
            let item = selectedImagesCollectionView.cellForItem(at: indexPath) as? UploadPostSelectedCell
            else { return }
        item.uploadComplete()
    }

    func setProgress(at index: Int, progress: Float) {
        let indexPath = IndexPath(item: index, section: 0)
        guard selectedImagesCollectionView.indexPathsForVisibleItems.contains(indexPath),
            let item = selectedImagesCollectionView.cellForItem(at: indexPath) as? UploadPostSelectedCell
            else { return }
        item.updateProgress(progress: progress)
    }
    
}

extension UploadPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pickerCollectionView {
            guard let galleryPhotosCount = photosFromGallery?.count else { return 0 }
            if galleryPhotosCount < Constants.defaultPickerCollectionViewItemsCount {
                return galleryPhotosCount + 1
            }
            return Constants.defaultPickerCollectionViewItemsCount
        } else if collectionView == selectedImagesCollectionView {
            guard let photosCount = presenter?.getCountOfUploadItems() else { return 0 }
            return photosCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pickerCollectionView {
            guard let photosCount = photosFromGallery?.count else { fatalError() }
            if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 {
                let cellIdentifier = Constants.openGalleryCollectionViewCell
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? OpenMoreCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                return cell
            }
            if indexPath.item < photosCount {
                let cellIdentifier = Constants.pickerCollectionViewCellReuseIdentifier
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumUploadCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                guard let asset = photosFromGallery?.object(at: indexPath.item) else { fatalError() }
                cell.identifier = asset.localIdentifier
                cell.configureCell(asset: asset, cellSize: flowLayout.itemSize)
                if let index = selectedItems.firstIndex(of: indexPath.item) {
                    cell.setSerialNumber(number: index + 1)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
                return cell
            }
        } else if collectionView == selectedImagesCollectionView {
            let cellIdentifier = Constants.selectedImageCollectionViewCellReuseIdentifier
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UploadPostSelectedCell else {
                fatalError(Constants.collectionViewInitFatalErrorDescription) }
            guard let uploadPhoto = presenter?.getUploadImage(at: indexPath) else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
            cell.asset = uploadPhoto.asset
            cell.identifier = uploadPhoto.asset.localIdentifier
            cell.vc = self
            cell.configureCell()
            return cell
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == pickerCollectionView {
            if indexPath.item == pickerCollectionView.numberOfItems(inSection: 0) - 1 {
                presenter?.presentGallery()
                collectionView.reloadData()
                return
            }
            if selectedItems.contains(indexPath.item) {
                guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
                if let i = selectedItems.firstIndex(of: indexPath.item) {
                    selectedItems.remove(at: i)
                }
                item.removeSerialNumber()
                collectionView.reloadData()
            } else {
                guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
                selectedItems.append(indexPath.item)
                item.setSerialNumber(number: selectedItems.count)
            }
        } else if collectionView == selectedImagesCollectionView {
            presenter?.cancelUpload(index: indexPath.item)
            updateDoneButtonState()
        }
    }
}

extension UploadPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let currentTheme = ThemeService.currentTheme()
        if textView.textColor == currentTheme.secondaryColor {
            textView.text = nil
            textView.textColor = currentTheme.primaryColor
            textView.font = textView.font?.withSize(Constants.textViewFontSize)
        }
        updateDoneButtonState()
    }
    
    
    
    func textViewDidEndEditing(_ textField: UITextView) {
        let currentTheme = ThemeService.currentTheme()
        if textView.text.isEmpty {
            textView.text = Constants.textViewPlaceholder
            textView.textColor = currentTheme.secondaryColor
            textView.font = textView.font?.withSize(Constants.textViewFontSize)
            updateDoneButtonState()
        } else {
            updateDoneButtonState()
        }
    }
}

private extension UploadPostViewController {    
    func configureUI() {
        photoPickerCollectionView.alpha = 0
        endSelectPhotosButton.alpha = 0
        photoPickerCollectionView.allowsMultipleSelection = true
        photoPickerCollectionView.collectionViewLayout = flowLayout
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemPressed))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: Constants.defaultToolbarHeight))
        keyboardToolbar.barStyle = .default
        let doneBarKeyboardItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        keyboardToolbar.items = [doneBarKeyboardItem]
        keyboardToolbar.sizeToFit()
        textView.inputAccessoryView = keyboardToolbar
        textView.delegate = self
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .authorized {
                        let allPhotosOptions = PHFetchOptions()
                        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: Constants.creationDateSortDescriptorKey, ascending: false)]
                        self.photosFromGallery = PHAsset.fetchAssets(with: allPhotosOptions)
                        self.photoPickerCollectionView.reloadData()
                    }
                }
            }
        }
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: Constants.creationDateSortDescriptorKey, ascending: false)]
        photosFromGallery = PHAsset.fetchAssets(with: allPhotosOptions)
        photoPickerCollectionView.reloadData()
        
        if !Reachability.isConnectedToNetwork() {
            showToast(message: Constants.internetConnectionErrorMessage)
        }
    }
    
    func configurePresentation() {
        updateDoneButtonState()
        let currentTheme = ThemeService.currentTheme()
        let primary = currentTheme.primaryColor
        let secondary = currentTheme.secondaryColor
        let background = currentTheme.backgroundColor
        let secondaryBackground = currentTheme.secondaryBackgroundColor
        
        view.backgroundColor = background
        cancelButton.isEnabled = false
        textView.text = Constants.textViewPlaceholder
        textView.textColor = secondary
        textView.font = textView.font?.withSize(Constants.textViewFontSize)
        textView.backgroundColor = secondaryBackground
        selectedImagesCollectionView.backgroundColor = background
        toolBar.backgroundColor = background
        pickerCollectionView.backgroundColor = background
        pickerView.backgroundColor = background
        openGalleryButton.backgroundColor = background
        openGalleryButton.setTitleColor(primary, for: .normal)
        openGalleryView.backgroundColor = background
        endSelectPhotosButton.tintColor = primary
        cancelButton.tintColor = primary
        addPhotoButton.tintColor = primary
        textViewContainer.backgroundColor = secondaryBackground
    }
    
    func hidePickerView() {
        self.photoPickerViewBottomConstraint.constant -= Constants.pickerViewConstraintMultiplier
        UIView.animate(withDuration: Constants.pickerViewAnimationDuration, animations: {
            self.view.layoutIfNeeded()
            self.pickerCollectionView.alpha = 0
            self.endSelectPhotosButton.alpha = 0
        }) { (complete) in
            if complete {
                self.addPhotoButton.isEnabled = true
                self.cancelButton.isEnabled = false
                self.updateDoneButtonState()
            }
        }
    }
    
    func presentPickerView() {
        self.photoPickerViewBottomConstraint.constant += Constants.pickerViewConstraintMultiplier
        UIView.animate(withDuration: Constants.pickerViewAnimationDuration, animations: {
            self.view.layoutIfNeeded()
            self.pickerCollectionView.alpha = 1.0
            self.endSelectPhotosButton.alpha = 1.0
        }) { (complete) in
            if complete {
                self.addPhotoButton.isEnabled = false
                self.cancelButton.isEnabled = true
            }
        }
    }
    
    func updateDoneButtonState() {
        if selectedImagesCollectionView.indexPathsForVisibleItems.isEmpty && (textView.text.isEmpty || textView.text == "What's new?") {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc func doneBarButtonItemPressed() {
        let message = textView.text
        presenter?.uploadPost(message: message, completion: { [weak self] (id) in
            guard let self = self else { return }
        }, createPostCompletion: { [weak self] (post) in
            guard let self = self else { return }
            self.presenter?.moveBack(newPost: post)
        })
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
