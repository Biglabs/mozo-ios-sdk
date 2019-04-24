//
//  ExpandImageView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/22/19.
//

import Foundation

class ExpandImageView: UIView {
    var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgCloseView: UIImageView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadViewFromNib()
    }
    
    var selectedIndex : Int = 0
        
    var names : [String] = [] {
        didSet {
            if collectionView != nil {
                print("Set name - collection view is existing")
                collectionView.reloadData()
                collectionView.performBatchUpdates(nil) { (result) in
                    if self.selectedIndex > 0 {
                        let indexPath = IndexPath(row: self.selectedIndex, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                    }
                }
            } else {
                print("Set name - collection view is not existing")
            }
        }
    }
    
    var layout = ExpandInfiniteLayout()
    
    func loadView(identifier: String) -> UIView {
        let bundle = BundleManager.mozoBundle()
        let nib = UINib(nibName: identifier, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return view
    }
    
    func loadViewFromNib() {
        let iden = "ExpandImageView"
        if !iden.isEmpty {
            containerView = loadView(identifier: iden)
            addSubview(containerView)
            updateImageLayout()
            setupCollectionView()
        }
    }
    
    func updateImageLayout() {
        let imgClose = UIImage(named: "ic_close", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgCloseView.image = imgClose
        imgCloseView.tintColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchClose))
        tap.numberOfTapsRequired = 1
        imgCloseView.isUserInteractionEnabled = true
        imgCloseView.addGestureRecognizer(tap)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: EXPAND_IMAGE_COLLECTION_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellWithReuseIdentifier: EXPAND_IMAGE_COLLECTION_VIEW_CELL_IDENTIFIER)
        collectionView.showsHorizontalScrollIndicator = false
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: collectionView.frame.size.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceHorizontal = false
    }
    
    @objc func touchClose() {
        containerView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
extension ExpandImageView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EXPAND_IMAGE_COLLECTION_VIEW_CELL_IDENTIFIER, for: indexPath) as! ExpandImageCollectionViewCell
        cell.imageName = names[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layout.loopCollectionViewIfNeeded()
    }
}
