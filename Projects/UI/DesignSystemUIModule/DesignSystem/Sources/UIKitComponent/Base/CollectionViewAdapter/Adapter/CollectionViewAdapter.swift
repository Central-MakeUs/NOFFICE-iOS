//
//  CollectionViewAdapter.swift
//  AlamofirePractice
//
//  Created by 이숭인 on 6/11/24.
//

import UIKit
import RxSwift
import RxCocoa

public final class CollectionViewAdapter: NSObject {
    var disposeBag = DisposeBag()
    
    weak var collectionView: UICollectionView?
    private var collectionViewLayoutKey: UInt8 = 0
    
    var dataSource: UICollectionViewDiffableDataSource<SectionItem, ListItem>!
    var registeredCellIdentifiers = Set<String>()
    var registeredSupplementaryCellIdentifiers = Set<String>()
    
    private let didSelectItemSubject = PublishSubject<ItemModelType>()
    var didSelectItemObservable: Observable<ItemModelType> {
        didSelectItemSubject.asObservable()
    }
    
    private let actionEventSubject = PublishSubject<ActionEventItem>()
    var actionEventObservable: Observable<ActionEventItem> {
        actionEventSubject.asObservable()
    }
    
    private let inputSectionSubject = BehaviorSubject<[SectionModelType]>(value: [])
    private var sections: [SectionModelType] {
        (try? inputSectionSubject.value()) ?? []
    }
    
    public init(with collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupCollectionDataSource()
        bindInputSections()
        bindDelegateEvent()
    }
}

// MARK: - CollectionView Action & Data Binding
extension CollectionViewAdapter {
    /// Data Binding
    private func setupCollectionDataSource() {
        guard let collectionView = collectionView else { return }
        
        dataSource = UICollectionViewDiffableDataSource<SectionItem, ListItem>(collectionView: collectionView) { (collectionView, indexPath, _) -> UICollectionViewCell? in
            guard let itemModel = self.itemModel(at: indexPath) else {
                return nil
            }
            
            // regist
            let reuseIdentifier = itemModel.viewType.getIdentifier()
            self.registerCellIfNeeded(with: itemModel)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            self.bindItemModelIfNeeded(to: cell, with: itemModel)
            self.bindActionEvent(with: cell)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (_, kind, indexPath) -> UICollectionReusableView? in
            guard let itemModel = self.headerFooterOfItemModel(at: indexPath, kind: kind) else {
                return nil
            }
            
            self.registerSupplementaryViewIfNeeded(with: itemModel, kind: kind)
            
            let reuseIdentifier = itemModel.viewType.getIdentifier()
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
            
            self.bindItemModelIfNeeded(to: cell, with: itemModel)
            self.bindActionEvent(with: cell)
            return cell
        }
    }
    
    /// Action Binding
    func setupInputSectionsIfNeeded(with sections: [SectionModelType]) {
        inputSectionSubject.onNext(sections)
    }
    
    private func bindInputSections() {
        inputSectionSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] sections in
                self?.updateSections(with: sections)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateSections(with inputSections: [SectionModelType]) {
        guard !inputSections.isEmpty else { return }
        
        reconfigureCollectionViewLayoutIfNeeded(with: inputSections)
        applySnapshot(with: inputSections)
    }
    
    private func reconfigureCollectionViewLayoutIfNeeded(with sectionModels: [SectionModelType]) {
        guard (objc_getAssociatedObject(self, &collectionViewLayoutKey) as? UICollectionViewCompositionalLayout) == nil else {
            return
        }
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let layoutModel = sectionModels[safe: sectionIndex]?.collectionLayout else {
                return nil
            }
            
            return self?.createLayoutSection(with: layoutModel)
        }
        
        objc_setAssociatedObject(self, &collectionViewLayoutKey, layout, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        collectionView?.setCollectionViewLayout(layout, animated: true)
    }
    
    private func applySnapshot(with sections: [SectionModelType]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionItem, ListItem>()
        
        sections.forEach { section in
            let sectionItem = SectionItem(sectionModel: section)
            let listItems = section.itemModels.map { ListItem(itemModel: $0) }
            
            snapshot.appendSections([sectionItem])
            snapshot.appendItems(listItems, toSection: sectionItem)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func bindDelegateEvent() {
        collectionView?.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let itemModel = self?.dataSource.itemIdentifier(for: indexPath)?.itemModel else {
                    return
                }
                
                self?.didSelectItemSubject.onNext(itemModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func cancelForPrepareForReuse(with view: UICollectionReusableView, disposeBag: DisposeBag) {
        view.rx.sentMessage(#selector(UICollectionReusableView.prepareForReuse))
            .subscribe(onNext: { _ in
                self.disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Cell DataBinding && ActionBinding && Regist
extension CollectionViewAdapter {
    private func bindActionEvent(with view: UICollectionReusableView) {
        guard let actionEventEmitable: ActionEventEmitable = convertProtocol(with: view) else { return }
        
        let actionEventDisposeBag = DisposeBag()
        
        actionEventEmitable.actionEventEmitter
            .subscribe(onNext: { [weak self] actionEvent in
                self?.actionEventSubject.onNext(actionEvent)
            })
            .disposed(by: actionEventDisposeBag)
        
        cancelForPrepareForReuse(with: view, disposeBag: actionEventDisposeBag)
    }
    
    private func bindItemModelIfNeeded(to cell: UICollectionReusableView, with itemModel: ItemModelType) {
        guard let cell = cell as? ItemModelBindableProtocol else { return }
        UIView.performWithoutAnimation {
            cell.bind(with: itemModel)
        }
    }
    
    private func registerCellIfNeeded(with itemModel: ItemModelType) {
        let reuseIdentifier = itemModel.viewType.getIdentifier()
        guard registeredCellIdentifiers.contains(reuseIdentifier) == false else { return }
        
        collectionView?.register(itemModel.viewType.getClass(), forCellWithReuseIdentifier: reuseIdentifier)
        registeredCellIdentifiers.insert(reuseIdentifier)
    }
    
    private func registerSupplementaryViewIfNeeded(with itemModel: ItemModelType, kind: String) {
        let reuseIdentifier = itemModel.viewType.getIdentifier()
        guard registeredSupplementaryCellIdentifiers.contains("\(kind)-\(reuseIdentifier)") == false else {
            print("::: 이미있음")
            return
        }
        
        print("::: 저장함")
        collectionView?.register(itemModel.viewType.getClass(), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        registeredSupplementaryCellIdentifiers.insert("\(kind)-\(reuseIdentifier)")
    }
}

// MARK: - Finder
extension CollectionViewAdapter {
    func itemModel(at indexPath: IndexPath) -> ItemModelType? {
        sections[safe: indexPath.section]?.itemModels[safe: indexPath.item]
    }
    
    func headerFooterOfItemModel(at indexPath: IndexPath, kind: String) -> ItemModelType? {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            print("::: header return")
            return sections[safe: indexPath.section]?.header
        case UICollectionView.elementKindSectionFooter:
            print("::: footer return")
            return sections[safe: indexPath.section]?.header
        default:
            return nil
        }
    }
    
    func findIndexPathByIdentifier(with identifier: String) -> IndexPath? {
        var target: IndexPath?
        sections.enumerated().forEach { index, section in
            if let row = section.itemModels.firstIndex(where: { $0.identifier == identifier }) {
                target = IndexPath(item: row, section: index)
            }
        }
        
        return target
    }
    
    func convertProtocol<P>(with view: UICollectionReusableView) -> P? {
        if let cell = view as? UICollectionViewCell,
           let target = (cell as? P) ?? cell.contentView.subviews.first as? P {
            return target
        } else {
            return nil
        }
    }
    
    private func createLayoutSection(with layoutModel: CompositionalLayoutModelType) -> NSCollectionLayoutSection {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: layoutModel.itemStrategy.value.widthDimension,
                                              heightDimension: layoutModel.itemStrategy.value.heightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: layoutModel.groupStrategy.value.widthDimension,
                                               heightDimension: layoutModel.groupStrategy.value.heightDimension)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = layoutModel.groupSpacing
        section.contentInsets = layoutModel.sectionInset
        section.orthogonalScrollingBehavior = layoutModel.scrollBehavior
        
        // header / footer
        if let headerStrategy = layoutModel.headerStrategy {
            let headerSize = NSCollectionLayoutSize(widthDimension: headerStrategy.value.widthDimension,
                                                    heightDimension: headerStrategy.value.heightDimension)
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems.append(header)
            print("section.boundarySupplementary Header > \(section.boundarySupplementaryItems)")
        }
        
        if let footerStrategy = layoutModel.footerStrategy {
            let footerSize = NSCollectionLayoutSize(widthDimension: footerStrategy.value.widthDimension,
                                                    heightDimension: footerStrategy.value.heightDimension)
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                     elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
            section.boundarySupplementaryItems.append(footer)
            print("section.boundarySupplementary Footer > \(section.boundarySupplementaryItems)")
        }
        
        return section
    }
}
