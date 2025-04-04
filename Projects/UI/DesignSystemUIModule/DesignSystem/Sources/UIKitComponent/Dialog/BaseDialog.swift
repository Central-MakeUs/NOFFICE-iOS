//
//  BaseDialog.swift
//  DesignSystemBookApp
//
//  Created by DOYEON LEE on 7/1/24.
//

import UIKit

import RxSwift
import Then
import SnapKit

/// Extension for set theme
public extension BaseDialog {
    func styled(
        variant: BasicDialogVariant = .shadow,
        shape: BasicDialogShape = .round
    ) {
        let colorTheme = BasicDialogColorTheme(variant: variant)
        let figureTheme = BasicDialogFigureTheme(shape: shape)
        
        self.colorTheme = colorTheme
        self.figureTheme = figureTheme
    }
}

/// Extension for open and close dialog
public extension BaseDialog {
    func open() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        guard let window = windowScene.windows.first
        else { return }
        
        // Add overlayView to UIWindow
        window.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalTo(window)
        }
        
        let duration = 0.3
        self.isHidden = false
        self.overlayView.alpha = 0
        self.backgroundView.alpha = 0
        
        UIView.animate(withDuration: duration) {
            self.overlayView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }
    
    func close() {
        let duration = 0.3
        UIView.animate(withDuration: duration) {
            self.overlayView.alpha = 0
            self.backgroundView.alpha = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isHidden = true
            }
        }
    }
}

public class BaseDialog: UIView {
    public typealias ViewBuilder = () -> [UIView]
    
    // MARK: Theme
    private var colorTheme: BasicDialogColorTheme? {
        didSet {
            updateCornerRadius()
            updateTheme()
            updateLayout()
        }
    }
    
    private var figureTheme: BasicDialogFigureTheme? {
        didSet {
            updateCornerRadius()
            updateTheme()
            updateLayout()
        }
    }
    
    // MARK: UIConstant
    private let pagePadding: CGFloat = 24
    
    // MARK: UI Component
    private let overlayView = UIView()
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .fullWhite
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    // MARK: Build component
    private var contentComponents: [UIView] = []
    
    // MARK: DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        updateCornerRadius()
        setupBind()
        updateTheme()
        updateLayout()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHierarchy()
        setupBind()
        updateCornerRadius()
        updateTheme()
        updateLayout()
    }
    
    public init(
        contentsBuilder: ViewBuilder
    ) {
        super.init(frame: .zero)
        
        contentComponents.append(contentsOf: contentsBuilder())
        
        setupHierarchy()
        updateCornerRadius()
        setupBind()
        updateTheme()
        updateLayout()
    }
    
    // MARK: Life cycle
    
    // MARK: Setup
    private func setupHierarchy() { 
        addSubview(overlayView)
        
        addSubview(backgroundView)
        
        backgroundView.addSubview(contentStackView)
        
        contentComponents.forEach {
            contentStackView.addArrangedSubview($0)
        }
    }
    
    private func setupBind() { }
    
    // MARK: Update
    private func updateCornerRadius() {
        guard let figureTheme = figureTheme else { return }
        
        let rounded = figureTheme.rounded().max
        
        backgroundView.layer.cornerRadius = rounded
    }
    
    private func updateTheme() { 
        guard let colorTheme = colorTheme else { return }
        
        // overaly
        let overlayColor = colorTheme.overlayColor().uiColor
        overlayView.backgroundColor = overlayColor
        
        // shadow
        let shadowColor = colorTheme.shadowColor().cgColor
        backgroundView.layer.shadowColor = shadowColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowRadius = 12
        
    }
    
    private func updateLayout() { 
        guard let figureTheme = figureTheme else { return }
        
        let padding = figureTheme.padding()
        
        overlayView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(UIScreen.main.bounds.height)
            $0.edges.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(pagePadding)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(padding.vertical ?? 0)
            $0.left.right.equalToSuperview().inset(padding.horizontal ?? 0)
            $0.bottom.equalTo(backgroundView.snp.bottom).inset(padding.vertical ?? 0)
        }
    }
}
