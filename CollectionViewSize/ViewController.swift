//
//  ViewController.swift
//  CollectionViewSize
//
//  Created by Seunghun Yang on 2022/03/19.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private var subViewController: SubViewController?
    
    var containerHeight: CGFloat = 400 {
        didSet {
            DispatchQueue.main.async {
                self.containerView.snp.updateConstraints { make in
                    make.height.equalTo(self.containerHeight)
                }
                self.containerView.layoutIfNeeded()
                self.subViewController?.invalidate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSubViewController()
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.height.equalTo(400)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupSubViewController() {
        let viewController = SubViewController()
        viewController.delegate = self
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        subViewController = viewController
    }
}

extension ViewController: SubViewControllerDelegate {
    func subViewController(_ subViewController: SubViewController, hasColorView: Bool) {
        containerHeight = hasColorView ? 300 : 400
    }
}


protocol SubViewControllerDelegate: AnyObject {
    func subViewController(_ subViewController: SubViewController, hasColorView: Bool)
}

class SubViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Cell
    
    class CustomCell: UICollectionViewCell {
        static let identifier: String = "CustomCell"
        
        // MARK: - Subviews
        
        private let someView: UIView = {
            let view = UIView()
            view.backgroundColor = .red
            return view
        }()
        
        // MARK: - Initializers
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }
        
        // MARK: - Setups
        
        private func setupViews() {
            addSubview(someView)
            contentView.addSubview(someView)
            someView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
    // MARK: - Subviews
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = .zero
        layout.minimumLineSpacing = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.identifier)
        return collectionView
    }()
    
    weak var delegate: SubViewControllerDelegate?
    
    // MARK: - Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Internal Methods
    
    func invalidate() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - DataSource and Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCell.identifier, for: indexPath)
        cell.backgroundColor = [.yellow, .blue][indexPath.item % 2]
        return cell
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let index = Int(offset.x / collectionView.frame.width)
        delegate?.subViewController(self, hasColorView: index % 2 == 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let index = Int(offset.x / collectionView.frame.width)
        print(offset, index, index % 2 == 0)
        delegate?.subViewController(self, hasColorView: index % 2 == 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
