//
//  BaseBadge.swift
//  DesignSystemApp
//
//  Created by DOYEON LEE on 7/14/24.
//

import UIKit

import RxSwift
import Then
import SnapKit

/// Extension for set theme
public extension BaseBadge {
    func styled(
        color: BasicBadgeColor = .green,
        variant: BasicBadgeVariant = .on
    ) {
        let colorTheme = BasicBadgeColorTheme(color: color, variant: variant)
        let figureTheme = BasicBadgeFigureTheme()
        
        self.colorTheme = colorTheme
        self.figureTheme = figureTheme
    }
}

public class BaseBadge: UIView {
    public typealias ViewBuilder = () -> [UIView]
    
    // MARK: Theme
    private var colorTheme: BasicBadgeColorTheme? {
        didSet {
            updateCornerRadius()
            updateTheme()
            updateLayout()
        }
    }
    
    private var figureTheme: BasicBadgeFigureTheme? {
        didSet {
            updateCornerRadius()
            updateTheme()
            updateLayout()
        }
    }
    
    // MARK: UIConstant
    
    // MARK: UI Component
    private lazy var backgroundView = UIView()
    
    private lazy var contentsStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    // MARK: Build component
    private var contentComponents: [UIView] = []
    
    // MARK: DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupBind()
        updateTheme()
        updateLayout()
        updateCornerRadius()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHierarchy()
        setupBind()
        updateTheme()
        updateLayout()
        updateCornerRadius()
    }
    
    public init(
        contentsBudiler: ViewBuilder
    ) {
        super.init(frame: .zero)
        
        contentComponents.append(contentsOf: contentsBudiler())
        
        setupHierarchy()
        setupBind()
        updateTheme()
        updateLayout()
        updateCornerRadius()
    }
    // MARK: Life cycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
        updateCornerRadius()
    }
    
    // MARK: Setup
    private func setupHierarchy() {
        self.addSubview(backgroundView)
        
        backgroundView.addSubview(contentsStack)
        
        contentComponents.forEach {
            contentsStack.addArrangedSubview($0)
        }
    }
    
    private func setupBind() { }
    
    // MARK: Update
    private func updateCornerRadius() {
        guard let figureTheme = figureTheme else { return }
        
        self.layer.cornerRadius = figureTheme.rounded().max
        self.layer.masksToBounds = true
    }
    
    private func updateTheme() {
        guard let colorTheme = colorTheme else { return }
        
        let foregroundColor = colorTheme.foregroundColor().uiColor
        let backgroundColor = colorTheme.backgroundColor().uiColor
        let iconForegroundColor = colorTheme.iconForegroundColor().uiColor
        
        backgroundView.backgroundColor = backgroundColor
        
        contentsStack.arrangedSubviews.forEach {
            if let label = $0 as? UILabel {
                label.textColor = foregroundColor
            } else if let image = $0 as? UIImageView {
                image.tintColor = iconForegroundColor
            }
        }
    }
    
    private func updateLayout() {
        guard let figureTheme = figureTheme else { return }
        
        let padding = figureTheme.padding()
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentsStack.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(padding.vertical ?? 0)
            $0.left.right.equalToSuperview().inset(padding.horizontal ?? 0)
        }
    }
}
