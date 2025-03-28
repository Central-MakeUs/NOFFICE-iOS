//
//  TextFieldBookViewController.swift
//  DesignSystemBookApp
//
//  Created by DOYEON LEE on 6/24/24.
//

import UIKit

import DesignSystem
import Assets

import RxSwift
import RxCocoa
import Then
import SnapKit

final class TextFieldBookViewController: UIViewController {
    // MARK: UI Component
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private lazy var sizeControlLabel = UILabel().then {
        $0.text = "size"
        $0.setTypo(.body1b)
    }
    
    private lazy var sizeControl = UISegmentedControl(
        items: Array(BasicTextFieldSize.allCases).map { $0.rawValue }
    ).then {
        $0.selectedSegmentIndex = 0
    }
    
    private lazy var variantControlLabel = UILabel().then {
        $0.text = "variant"
        $0.setTypo(.body1b)
    }
    
    private lazy var variantControl = UISegmentedControl(
        items: Array(BasicTextFieldVariant.allCases).map { $0.rawValue }
    ).then {
        $0.selectedSegmentIndex = 0
    }

    private lazy var shapeControlLabel = UILabel().then {
        $0.text = "shape"
        $0.setTypo(.body1b)
    }
    
    private lazy var shapeControl = UISegmentedControl(
        items: Array(BasicTextFieldShape.allCases).map { $0.rawValue }
    ).then {
        $0.selectedSegmentIndex = 0
    }
    
    private lazy var stateControlLabel = UILabel().then {
        $0.text = "state"
        $0.setTypo(.body1b)
    }
    
    private lazy var stateControl = UISegmentedControl(
        items: ["normal", "disabled", "error", "success"]
    ).then {
        $0.selectedSegmentIndex = 0
    }
    
    private lazy var colorLabels: [UILabel] = BasicTextFieldColor.allCases.map { color in
        UILabel().then {
            $0.text = color.rawValue
            $0.setTypo(.body3)
            $0.textColor = .grey400
        }
    }
    
    private lazy var textFields: [BaseTextField] = BasicTextFieldColor.allCases.map { _ in
        BaseTextField().then {
            $0.styled()
            $0.placeholder = "Placeholder"
        }
    }
    
    private lazy var textFieldWithTextCountLabel = UILabel().then {
        $0.text = "With text count"
        $0.setTypo(.body1b)
    }
    
    private lazy var textFieldDescription = UILabel().then {
        $0.text = "0/10"
        $0.setTypo(.body3)
    }
    
    private lazy var textFieldWithTextCount = BaseTextField(
        descriptionBuilder: { [weak self] in
            guard let self = self else { return [] }
            
            return [
                BaseSpacer(),
                self.textFieldDescription
            ]
        }
    ).then {
        $0.styled()
        $0.placeholder = "Placeholder"
    }
    
    private lazy var textFieldWithDeleteLabel = UILabel().then {
        $0.text = "With delete button"
        $0.setTypo(.body1b)
    }
    
    private lazy var textFieldDeleteButton = UIImageView(image: .imgXCircle).then {
        $0.contentMode = .scaleAspectFit
        $0.frame.size = CGSize(width: 20, height: 20)
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var textFieldWithDelete = BaseTextField(
        suffixBuilder: { [weak self] in
            guard let self = self else { return [] }
            
            return [textFieldDeleteButton]
        }
    ).then {
        $0.styled()
        $0.placeholder = "Placeholder"
    }
    
    private lazy var textFieldWithOthersLabel = UILabel().then {
        $0.text = "With Others"
        $0.setTypo(.body1b)
    }
    
    private lazy var textFieldWithOthers = BaseTextField(
        titleBuilder: {
            [
                UIImageView(
                    image: UIImage(systemName: "checkmark.circle")
                ).then {
                    $0.snp.makeConstraints {
                        $0.width.equalTo(20)
                    }
                },
                UILabel().then {
                    $0.text = "Title"
                    $0.setTypo(.body1b)
                    $0.textColor = .grey800
                }
            ]
        },
        descriptionBuilder: {
            [
                UIImageView(
                    image: UIImage(systemName: "exclamationmark.circle.fill")
                ).then {
                    $0.snp.makeConstraints {
                        $0.width.height.equalTo(15)
                    }
                },
                UILabel().then {
                    $0.text = "Description"
                    $0.setTypo(.body3)
                    $0.textColor = .grey400
                }
            ]
        }
    ).then {
        $0.styled()
        $0.placeholder = "Placeholder"
    }

    // MARK: DisposeBag
    private let disposeBag = DisposeBag()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupHierarchy()
        setupLayout()
        setupBind()
    }
    
    // MARK: Setup methods
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(variantControlLabel)
        stackView.addArrangedSubview(variantControl)
        stackView.addArrangedSubview(sizeControlLabel)
        stackView.addArrangedSubview(sizeControl)
        stackView.addArrangedSubview(shapeControlLabel)
        stackView.addArrangedSubview(shapeControl)
        stackView.addArrangedSubview(stateControlLabel)
        stackView.addArrangedSubview(stateControl)
        
        textFields.enumerated().forEach { index, textField in
            stackView.addArrangedSubview(colorLabels[index])
            stackView.addArrangedSubview(textField)
        }
        
        // Textfield with text count
        stackView.addArrangedSubview(textFieldWithTextCountLabel)
        stackView.addArrangedSubview(textFieldWithTextCount)
        
        // Textfield with delete button
        stackView.addArrangedSubview(textFieldWithDeleteLabel)
        stackView.addArrangedSubview(textFieldWithDelete)
        
        // Textfield with others
        stackView.addArrangedSubview(textFieldWithOthersLabel)
        stackView.addArrangedSubview(textFieldWithOthers)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
            $0.height.equalTo(stackView.snp.height).offset(32)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview().inset(pagePadding)
            $0.centerX.equalToSuperview()
        }
        
        sizeControl.snp.makeConstraints {
            $0.width.equalTo(stackView.snp.width)
        }
        
        variantControl.snp.makeConstraints {
            $0.width.equalTo(stackView.snp.width)
        }
        
        shapeControl.snp.makeConstraints {
            $0.width.equalTo(stackView.snp.width)
        }
        
        stateControl.snp.makeConstraints {
            $0.width.equalTo(stackView.snp.width)
        }
    }

    private func setupBind() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            variantControl.rx.selectedSegmentIndex,
            sizeControl.rx.selectedSegmentIndex,
            shapeControl.rx.selectedSegmentIndex,
            stateControl.rx.selectedSegmentIndex
        )
        .observe(on: MainScheduler.instance)
        .withUnretained(self)
        .subscribe(onNext: { owner, value in
            owner.textFields.enumerated().forEach { index, textField in
                textField.styled(
                    variant: BasicTextFieldVariant.allCases[value.0],
                    color: BasicTextFieldColor.allCases[index],
                    size: BasicTextFieldSize.allCases[value.1],
                    shape: BasicTextFieldShape.allCases[value.2],
                    state: owner.convertState(value.3)
                )
                textField.disabled = value.3 == 1
            }
            
            owner.textFieldWithTextCount.styled(
                variant: BasicTextFieldVariant.allCases[value.0],
                color: .gray,
                size: BasicTextFieldSize.allCases[value.1],
                shape: BasicTextFieldShape.allCases[value.2],
                state: owner.convertState(value.3)
            )
            owner.textFieldWithTextCount.disabled = value.3 == 1
            
            owner.textFieldWithDelete.styled(
                variant: BasicTextFieldVariant.allCases[value.0],
                color: .gray,
                size: BasicTextFieldSize.allCases[value.1],
                shape: BasicTextFieldShape.allCases[value.2],
                state: owner.convertState(value.3)
            )
            owner.textFieldWithDelete.disabled = value.3 == 1
            
            owner.textFieldWithOthers.styled(
                variant: BasicTextFieldVariant.allCases[value.0],
                color: .gray,
                size: BasicTextFieldSize.allCases[value.1],
                shape: BasicTextFieldShape.allCases[value.2],
                state: owner.convertState(value.3)
            )
            owner.textFieldWithOthers.disabled = value.3 == 1
        })
        .disposed(by: disposeBag)
        
        textFieldWithTextCount.onChange
            .withUnretained(self)
            .subscribe { owner, value in
                owner.textFieldDescription.text = "\(value?.count ?? 0)/10"
            }
            .disposed(by: disposeBag)
        
        let deleteTapGesture = UITapGestureRecognizer()
        textFieldDeleteButton.addGestureRecognizer(deleteTapGesture)
        
        deleteTapGesture.rx.event
            .map { _ in "" }
            .bind(to: textFieldWithDelete.text)
            .disposed(by: disposeBag)
    }
    
    func convertState(_ stateIndex: Int) -> TextFieldState {
        switch stateIndex {
        case 0:
            return TextFieldState.allCases[0]
        case 1:
            return .normal
        default:
            return TextFieldState.allCases[stateIndex - 1]
        }
    }
}
