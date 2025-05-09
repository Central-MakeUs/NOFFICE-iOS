//
//  AnnouncementSection.swift
//  HomePresent
//
//  Created by DOYEON LEE on 7/17/24.
//

import UIKit

import DesignSystem
import Assets

import RxSwift
import RxGesture

struct AnnouncementSection: CompositionalSection {
    typealias Header = AnnouncementSectionHeaderView
    
    // MARK: Compositional
    var layout: CompositionalLayout {
        let scrollItemLayout: [CompositionalItemLayout]  =
        [
            .item(
                size: .init(
                    width: .fractionalWidth(1.0),
                    height: .estimated(ComponentConstant.organizationCardHeight)
                )
            )
        ]
        
        let nonScrollItemLayout: [CompositionalItemLayout] = [
            .item(
                size: .init(
                    width: .fractionalWidth(0.75),
                    height: .estimated(ComponentConstant.organizationCardHeight)
                )
            ),
            .item(
                size: .init(
                    width: .fractionalWidth(0.25),
                    height: .estimated(ComponentConstant.organizationCardHeight)
                )
            )
        ]
        
        return .init(
            groupLayout: .init(
                size: .init(
                    width: scrollDisabled ? .fractionalWidth(1.0) : .fractionalWidth(0.7),
                    height: .estimated(ComponentConstant.organizationCardHeight)
                ),
                groupSpacing: GlobalViewConstant.pagePadding,
                items: scrollDisabled ? nonScrollItemLayout : scrollItemLayout,
                itemSpacing: GlobalViewConstant.pagePadding
            ),
            headerSize: .init(width: .fractionalWidth(1.0), height: .absolute(72)),
            sectionInset: .init(
                top: 0,
                leading: GlobalViewConstant.pagePadding,
                bottom: 0,
                trailing: scrollDisabled ? 0 : GlobalViewConstant.pagePadding
            ),
            scrollBehavior: scrollDisabled ? .none : .groupPaging
        )
    }
    
    // MARK: Data
    let identifier: String
    
    let organizationName: String
    
    let scrollDisabled: Bool
    
    let items: [any CompositionalItem]
    
    init(
        identifier: String,
        organizationName: String,
        scrollDisabled: Bool = false,
        items: [any CompositionalItem]
    ) {
        self.identifier = identifier
        self.organizationName = organizationName
        self.scrollDisabled = scrollDisabled
        self.items = items
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(organizationName)
    }
}

class AnnouncementSectionHeaderView: UIView, CompositionalReusableView {
    typealias Section = AnnouncementSection
    
    // MARK: UI Component
    // - Organization name label
    private lazy var label = UILabel().then {
        $0.textColor = .grey800
        $0.textAlignment = .left
        $0.setTypo(.heading4)
    }
    
    // - Right arrow icon
    private lazy var icon = UIImageView(image: .iconChevronRight).then {
        $0.tintColor = .grey800
        $0.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        addSubview(label)
        addSubview(icon)
        
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(14)
        }
        
        icon.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
        }
    }
    
    func configure(with section: Section) {
        label.text = section.organizationName
    }
}
