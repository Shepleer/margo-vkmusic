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
    }
    
    var smallFlowLayout = SmallPhotoPickerFlowLayout()
    var bigFlowLayout = BigPhotoPickerFlowLayout()
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
        subscribeKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
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
            if galleryPhotosCount < 31 {
                return galleryPhotosCount + 1
            }
            return 30 + 1
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
                cell.configureCell(asset: asset, cellSize: bigFlowLayout.itemSize)
                if let k = selectedItems.firstIndex(of: indexPath.item) {
                    cell.setSerialNumber(number: k + 1)
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
            textView.font = textView.font?.withSize(15)
        }
        updateDoneButtonState()
    }
    
    
    
    func textViewDidEndEditing(_ textField: UITextView) {
        let currentTheme = ThemeService.currentTheme()
        if textView.text.isEmpty {
            textView.text = Constants.textViewPlaceholder
            textView.textColor = currentTheme.secondaryColor
            textView.font = textView.font?.withSize(22)
            updateDoneButtonState()
        } else {
            updateDoneButtonState()
        }
    }
}

private extension UploadPostViewController {
    func updateCollectionViewPresentationIfNeedet() {
        guard let countOfVisibleItems = photoPickerCollectionView.indexPathsForSelectedItems else { return }
        if countOfVisibleItems.isEmpty {
            if photoPickerCollectionView.collectionViewLayout == bigFlowLayout {
                photoPickerCollectionView.setCollectionViewLayout(smallFlowLayout, animated: true)
                collectionViewHeightConstraint.constant = 150
                photoPickerCollectionView.layoutIfNeeded()
            }
        } else {
            if photoPickerCollectionView.collectionViewLayout == smallFlowLayout {
                photoPickerCollectionView.setCollectionViewLayout(bigFlowLayout, animated: true)
                collectionViewHeightConstraint.constant = 357
                photoPickerCollectionView.layoutIfNeeded()
            }
        }
    }
    
    func configureUI() {
        photoPickerCollectionView.alpha = 0
        endSelectPhotosButton.alpha = 0
        photoPickerCollectionView.allowsMultipleSelection = true
        photoPickerCollectionView.collectionViewLayout = smallFlowLayout
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemPressed))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 50))
        keyboardToolbar.barStyle = .default
        let doneBarKeyboardItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        keyboardToolbar.items = [doneBarKeyboardItem]
        keyboardToolbar.sizeToFit()
        textView.inputAccessoryView = keyboardToolbar
        textView.delegate = self
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosFromGallery = PHAsset.fetchAssets(with: allPhotosOptions)
        photoPickerCollectionView.reloadData()
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
        textView.font = textView.font?.withSize(22)
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
    
    func subscribeKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func hidePickerView() {
        self.photoPickerViewBottomConstraint.constant -= 150
        UIView.animate(withDuration: 0.3, animations: {
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
        self.photoPickerViewBottomConstraint.constant += 150
        UIView.animate(withDuration: 0.3, animations: {
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
        presenter?.uploadPost(message: message, completion: { (id) in
        }, createPostCompletion: { (post) in
            self.presenter?.moveBack(newPost: post)
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        //if photoPickerCollectionView.isHidden {
        //    photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - photoPickerCollectionView.bounds.height - 35
        //} else {
        //    photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - 35
        //}
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //if photoPickerCollectionView.isHidden {
        //    photoPickerViewBottomConstraint.constant = -photoPickerCollectionView.bounds.height
        //} else {
        //    photoPickerViewBottomConstraint.constant = 0
        //}
    }
}
