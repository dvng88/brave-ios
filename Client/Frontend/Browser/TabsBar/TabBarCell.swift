/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import BraveShared

class TabBarCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeTab), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "close_tab_bar").template, for: .normal)
        button.tintColor = .braveLabel
        // Close button is a bit wider to increase tap area, this aligns the 'X' image closer to the right.
        button.imageEdgeInsets.left = 6
        return button
    }()
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .braveSeparator
    }
    
    let separatorLineRight = UIView().then {
        $0.backgroundColor = .braveSeparator
        $0.isHidden = true
    }
    
    var currentIndex: Int = -1 {
        didSet {
            isSelected = currentIndex == tabManager?.currentDisplayedIndex
        }
    }
    weak var tab: Tab?
    weak var tabManager: TabManager?
    
    var closeTabCallback: ((Tab) -> Void)?
    
    private let deselectedOverlayView = UIView().then {
        $0.backgroundColor = UIColor {
            if $0.userInterfaceStyle == .dark {
                return UIColor.black.withAlphaComponent(0.25)
            }
            return UIColor.black.withAlphaComponent(0.05)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondaryBraveBackground
        
        [deselectedOverlayView, closeButton, titleLabel, separatorLine, separatorLineRight].forEach { contentView.addSubview($0) }
        initConstraints()
        
        isSelected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initConstraints() {
        deselectedOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).inset(16)
            make.right.equalTo(closeButton.snp.left)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.right.equalTo(self).inset(2)
            make.width.equalTo(30)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.width.equalTo(0.5)
            make.height.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        separatorLineRight.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.width.equalTo(0.5)
            make.height.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configure()
        }
    }
    
    func configure() {
        if isSelected {
            titleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
            titleLabel.alpha = 1.0
            closeButton.isHidden = false
            deselectedOverlayView.isHidden = true
        }
            // Prevent swipe and release outside- deselects cell.
        else if currentIndex != tabManager?.currentDisplayedIndex {
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.alpha = 0.6
            closeButton.isHidden = true
            deselectedOverlayView.isHidden = false
        }
    }
    
    @objc func closeTab() {
        guard let tab = tab else { return }
        closeTabCallback?(tab)
    }
    
    fileprivate var titleUpdateScheduled = false
    func updateTitleThrottled(for tab: Tab) {
        if titleUpdateScheduled {
            return
        }
        titleUpdateScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.titleUpdateScheduled = false
            strongSelf.titleLabel.text = tab.displayTitle
        }
    }
}
