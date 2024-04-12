//
//  ViewController.swift
//  DiffableDataSourceExample
//
//  Created by Squid Yu on 2024/4/12.
//

import UIKit

struct SelectedModel: Identifiable {
    let id = UUID()

    var selected: Bool
}

class ViewController: UIViewController {
    
    // MARK: Mock Model Repository
    var fakeItems = [
        SelectedModel(selected: false),
        SelectedModel(selected: false),
        SelectedModel(selected: false),
        SelectedModel(selected: false),
    ]
    
    // MARK: Collection View
    
    enum Section {
        case main
    }
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
            var section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: environment)
            return section
        })
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SelectedModel.ID> = {
        let cell = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> { [unowned self] cell, indexPath, item in
            var context = cell.defaultContentConfiguration()
            context.text = item.uuidString
            
            if let item = fakeItems.first(where: { $0.id == item }) {
                context.secondaryText = "Selected: " + String(describing: item.selected)
            } else {
                context.secondaryText = "Selected: nil"
            }
            cell.contentConfiguration = context
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, SelectedModel.ID>.init(collectionView: collectionView) { [unowned self] collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupFakeData()
    }
}

// MARK: - Private Methods

private extension ViewController {
    func configureViews() {
        view.addSubview(collectionView)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", metrics: nil, views: ["collectionView": collectionView])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", metrics: nil, views: ["collectionView": collectionView])
        NSLayoutConstraint.activate(horizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    func setupFakeData() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, SelectedModel.ID>()
        snapShot.appendSections([.main])
        let uuids = fakeItems.map { $0.id }
        snapShot.appendItems(uuids)
        dataSource.apply(snapShot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var item = fakeItems[indexPath.item]
        item.selected = !item.selected
        fakeItems[indexPath.item] = item
        
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([item.id])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
