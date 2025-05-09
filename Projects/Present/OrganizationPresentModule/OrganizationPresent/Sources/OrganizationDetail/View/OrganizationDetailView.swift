//
//  OrganizationDetailView.swift
//  OrganizationPresent
//
//  Created by DOYEON LEE on 7/31/24.
//

import UIKit

import DesignSystem
import Assets

import SnapKit
import Then

class OrganizationDetailView: BaseView {
    // MARK: UI Constant
    private let organizationProfileCardSize: CGFloat = 86
    
    // MARK: UI Component
    // - Navigation bar
    lazy var navigationBar = NofficeNavigationBar()
    
    // - Scroll view
    lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
    }
    
    // - Contents view
    lazy var contentView = UIView().then {
        $0.backgroundColor = .grey50
    }
    
    // - Stack view
    lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = GlobalViewConstant.spacingUnit * 3
    }
    
    // - Organization profile
    lazy var organizationProfile = BaseHStack(
        spacing: GlobalViewConstant.spacingUnit * 3
    ) {
        [
            organizationImageView,
            BaseVStack(spacing: 10) {
                [
                    BaseSpacer(),
                    organizationNameLabel,
                    organizationCategoryBadges,
                    BaseSpacer()
                ]
            }
        ]
    }
    
    lazy var organizationImageView = UIImageView(image: .imgProfileGroup).then {
        $0.setSize(
            width: organizationProfileCardSize,
            height: organizationProfileCardSize
        )
        $0.layer.cornerRadius = organizationProfileCardSize / 2
        $0.layer.masksToBounds = true
    }
    
    lazy var organizationNameLabel = UILabel().then {
        $0.text = "Skeleton dummy"
        $0.setTypo(.heading3)
        $0.textColor = .grey800
    }
    
    lazy var organizationCategoryBadges = BaseHStack {
        [
            BaseBadge(contentsBudiler: {
                [
                    UILabel().then {
                        $0.text = "IT"
                        $0.setTypo(.body3b)
                    }
                ]
            }).then {
                $0.styled(color: .green, variant: .weak)
            },
            BaseBadge(contentsBudiler: {
                [
                    UILabel().then {
                        $0.text = "창업"
                        $0.setTypo(.body3b)
                    }
                ]
            }).then {
                $0.styled(color: .green, variant: .weak)
            },
            BaseSpacer()
        ]
    }
    
    // - Organization participant description
    lazy var organizationParticipantDescription = BaseHStack(
        alignment: .center,
        distribution: .equalSpacing
    ) {
        [
            BaseSpacer(),
            UILabel().then {
                $0.text = "Leader"
                $0.setTypo(.body1m)
                $0.textColor = .grey400
            },
            leaderCountLabel,
            UILabel().then {
                $0.text = "Member"
                $0.setTypo(.body1m)
                $0.textColor = .grey400
            },
            memberCountLabel,
            BaseSpacer()
        ]
    }
    
    lazy var leaderCountLabel = UILabel().then {
        $0.text = "0"
        $0.setTypo(.body1m)
        $0.textColor = .grey800
    }
    
    lazy var memberCountLabel = UILabel().then {
        $0.text = "0"
        $0.setTypo(.body1m)
        $0.textColor = .grey800
    }
    
    // - Join waitlist button
    lazy var joinWaitlistButton = BaseButton {
        [
            UIImageView(image: .iconLoading),
            UILabel().then {
                $0.text = "가입을 대기 중인 멤버가 있어요!"
                $0.setTypo(.body1b)
            }
        ]
    }.then {
        $0.styled(variant: .outline, color: .green, size: .medium)
        $0.isHidden = true
    }
    
    // - Announcement list collection view
    lazy var announcementsCard = BaseCard(
        contentsBuilder: {
            [
                announcementsCollectionView
            ]
        }
    ).then {
        $0.styled(variant: .translucent, color: .background, padding: .medium)
    }
    
    lazy var announcementsCollectionView = CompositionalCollectionView().then {
        $0.isScrollEnabled = false
    }
    
    // MARK: Setup
    public override func setupHierarchy() {
        backgroundColor = .grey50
        
        addSubview(navigationBar)
        
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(organizationProfile)
        
        stackView.addArrangedSubview(BaseDivider(color: .grey200))
        
        stackView.addArrangedSubview(
            BaseSpacer(size: GlobalViewConstant.spacingUnit * 3)
        )
        
        stackView.addArrangedSubview(organizationParticipantDescription)
        
        stackView.addArrangedSubview(
            BaseSpacer(size: GlobalViewConstant.spacingUnit * 2)
        )
        
        stackView.addArrangedSubview(joinWaitlistButton)
        
        stackView.addArrangedSubview(
            BaseSpacer(size: GlobalViewConstant.spacingUnit * 2)
        )
        
        stackView.addArrangedSubview(announcementsCard)
    }
    
    public override func setupLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
                .offset(GlobalViewConstant.spacingUnit * 2)
            $0.left.right.equalToSuperview()
                .inset(GlobalViewConstant.pagePaddingLarge)
            $0.bottom.equalToSuperview()
        }
    }
}
