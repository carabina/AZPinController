//
//  AZNumPadView.swift
//  AZPinController
//
//  Created by Azamat Kalmurzayev on 2/24/18.
//

import Foundation
import UIKit;
import SnapKit;

protocol AZNumPadDelegate: class {
    /// Called on delegate when value is entered in numpad
    ///
    /// - Parameters:
    ///   - numPad: caller Numpad instance
    ///   - enteredValue: input value
    func numPad(_ numPad: AZNumPadView, enteredValue: String);
    /// Called on delegate when delete button tapped on numpad
    ///
    /// - Parameter numPad: caller Numpad instance
    func deleteTappedIn(numPad: AZNumPadView);
}

class AZNumPadView: UIView, AZNumPadButtonDelegate {
    var mainColor: UIColor? {
        didSet {
            self.adjustColors();
        }
    };
    var font: UIFont? {
        didSet {
            if self.font == nil { return }
            self._numPadButtons.forEach {
                $0.font = self.font!;
            }
        }
    };
    var numPadAnimateTap: Bool = true {
        didSet {
            self._numPadButtons.forEach {
                $0.tapAnimate = self.numPadAnimateTap;
            }
        }
    };
    var buttonWidth: CGFloat? {
        didSet {
            if self.buttonWidth == nil { return }
            self.removeAllSubviews();
            self.populateButtons();
        }
    };
    // todo: use palette
    var deleteButtonImage: UIImage!;
    weak var delegate: AZNumPadDelegate?;
    private var _numPadButtons: [AZNumPadButton] = [];
    /// used to align bottom-left button in AZPinViewController
    var leftMostView: UIView?
    /// used to align bottom-right button in AZPinViewController
    var rightMostView: UIView?
    // MARK: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initiateViews();
    }
    
    convenience init() {
        self.init(frame: CGRect.zero);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /// Initiates its constraints and populates numpad buttons with their constraints
    private func initiateViews() {
        self.backgroundColor = UIColor.clear;
        self.snp.makeConstraints {
            $0.height.equalTo(self.snp.width).multipliedBy(11.0 / 8);
        };
        self.populateButtons();
    }
    
    /// Creates and adds NumPadButtons to NumPad
    private func populateButtons() {
        // 1. adding buttons one through nine
        for i in 1...9 {
            let row = (i - 1) / 3;
            let col = (i - 1) % 3;
            let button = AZNumPadButton();
            button.buttonText = String(i);
            button.valueText = String(i);
            button.lettersText = lettersForNum(i);
            button.delegate = self;
            self.addSubview(button);
            button.snp.makeConstraints {
                self.resolveButtonWidth($0.width);
                $0.height.equalTo(button.snp.width);
                $0.centerX.equalTo(self).multipliedBy((1 + Double(col) * 3) / 4);
                $0.centerY.equalTo(self).multipliedBy((1 + Double(row) * 3) / 5.5);
            };
            if i == 1 {
                leftMostView = button
            } else if i == 9 {
                rightMostView = button
            }
            self._numPadButtons.append(button);
        }
        // 2. adding the last zero button
        let zeroButton = AZNumPadButton();
        zeroButton.buttonText = String("0");
        zeroButton.valueText = String("0");
        zeroButton.delegate = self;
        self.addSubview(zeroButton);
        zeroButton.snp.makeConstraints {
            self.resolveButtonWidth($0.width);
            $0.height.equalTo(zeroButton.snp.width);
            $0.centerX.equalTo(self);
            $0.centerY.equalTo(self).multipliedBy(10.0 / 5.5);
        };
        self._numPadButtons.append(zeroButton);
        // 3. adjust colors for buttons
        self.adjustColors();
        
        // 4. adding delete button
        let deleteButton = UIButton();
        deleteButton.backgroundColor = UIColor.clear;
        deleteButton.setImage(self.deleteButtonImage, for: .normal);
        deleteButton.addTarget(
            self, action: #selector(deleteTapped), for: .touchUpInside);
        self.addSubview(deleteButton);
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(zeroButton);
            $0.height.equalTo(deleteButton.snp.width);
            $0.centerX.equalTo(self).multipliedBy(7.0 / 4);
            $0.centerY.equalTo(zeroButton);
        };
    }
    
    private func lettersForNum(_ num: Int) -> String? {
        switch num {
        case 2:
            return "ABC"
        case 3:
            return "DEF"
        case 4:
            return "GHI"
        case 5:
            return "JKL"
        case 6:
            return "MNO"
        case 7:
            return "PQRS"
        case 8:
            return "TUV"
        case 9:
            return "WXYZ"
        default:
            return nil
        }
    }
    
    @objc private func deleteTapped() {
        self.delegate?.deleteTappedIn(numPad: self);
    }
    
    private func resolveButtonWidth(_ width: ConstraintMakerExtendable) {
        // NOTE: button size is numpad's quarter width and margins are 1/8 width
        let buttonWidthPortion = 1.0 / 4;
        if self.buttonWidth != nil {
            width.equalTo(self.buttonWidth!);
        } else {
            width.equalTo(self.snp.width).multipliedBy(buttonWidthPortion);
        }
    }
    
    private func adjustColors() {
        if self.mainColor != nil {
            self._numPadButtons.forEach {
                $0.mainColor = self.mainColor!;
            }
        }
    }
    
    func numPadButtonTapped(_ button: AZNumPadButton) {
        if button.valueText == nil { return }
        self.delegate?.numPad(self, enteredValue: button.valueText!);
    }
}
