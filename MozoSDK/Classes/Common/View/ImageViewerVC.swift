//
//  ImageViewerVC.swift
//  MozoSDK
//
//  Created by MAC on 22/03/2022.
//

import Foundation

class ImageViewerVC: UIViewController {
    
    private var paths: [String] = []
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        self.view.backgroundColor = .black
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        ExpandImageCollectionViewCell.register(collectionView)
        
        collectionView.performBatchUpdates(nil) { (result) in
            let indexPath = IndexPath(row: self.selectedIndex, section: 0)
            if let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame {
                collectionView.scrollRectToVisible(rect, animated: false)
            }
        }
        collectionView.reloadData()
        
        let closeSize: CGFloat = 42
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle(nil, for: .normal)
        closeButton.setImage(
            "ic_close".asMozoImage()?.sd_resizedImage(
                with: CGSize(width: closeSize / 2, height: closeSize / 2),
                scaleMode: .aspectFit
            )?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        
        closeButton.tintColor = .white
        closeButton.backgroundColor = .lightGray.withAlphaComponent(0.5)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(self.touchedClose), for: .touchUpInside)
        closeButton.layer.cornerRadius = closeSize / 2
        closeButton.clipsToBounds = true
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: closeSize),
            closeButton.heightAnchor.constraint(equalToConstant: closeSize)
        ])
    }
    
    @objc func touchedClose() {
        dismiss(animated: true)
    }
    
    class func launch(_ parent: UIViewController, _ paths: [String], _ selected: Int = 0) {
        let vc = ImageViewerVC()
        vc.paths = paths
        vc.selectedIndex = selected
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        parent.present(vc, animated: true)
    }
}
extension ImageViewerVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExpandImageCollectionViewCell",
            for: indexPath
        ) as! ExpandImageCollectionViewCell
        cell.imageName = paths[indexPath.row]
        return cell
    }
}
