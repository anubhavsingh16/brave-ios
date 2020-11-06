// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Shared
import BraveShared
import BraveUI

class DefaultBrowserIntroCalloutViewController: UIViewController {
    
    private let openSettingsButton = Button().then {
        $0.setTitle(Strings.defaultBrowserIntroOpenSettingsButtonText, for: .normal)
        $0.backgroundColor = BraveUX.braveOrange
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.appearanceTextColor = .white
        $0.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        $0.contentEdgeInsets = .init(top: 0, left: 25, bottom: 0, right: 25)
        $0.layer.cornerRadius = 22
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle(Strings.defaultBrowserIntroSkipButtonText, for: .normal)
        $0.appearanceTextColor = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        openSettingsButton.addTarget(self, action: #selector(openSettingsAction), for: .touchUpInside)
    }
    
    @objc func cancelAction() {
        dismiss(animated: true)
    }
    
    @objc func openSettingsAction() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
        
        cancelAction()
    }

    private func setupViews() {
        let textStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 16
            
            $0.addStackViewItems(
                .view(UILabel().then {
                    $0.text = Strings.defaultBrowserIntroPrimaryText
                    $0.numberOfLines = 0
                    $0.font = .systemFont(ofSize: 28, weight: .regular)
                    $0.textAlignment = .center
                    $0.appearanceTextColor = .black
                }),
                .view(UILabel().then {
                    $0.text = Strings.defaultBrowserIntroSecondaryText
                    $0.numberOfLines = 0
                    $0.textAlignment = .center
                    $0.font = .systemFont(ofSize: 17, weight: .regular)
                    $0.appearanceTextColor = .black
                }),
                .view(UILabel().then {
                    $0.text = Strings.defaultBrowserIntroTertiaryText
                    $0.numberOfLines = 0
                    $0.textAlignment = .center
                    $0.font = .systemFont(ofSize: 17, weight: .regular)
                    $0.appearanceTextColor = #colorLiteral(red: 0.5254901961, green: 0.5568627451, blue: 0.5882352941, alpha: 1)
                })
            )
        }
        
        let buttonsStackView = UIStackView().then {
            $0.axis = .vertical
            
            $0.addStackViewItems(
                .view(openSettingsButton),
                .customSpace(8),
                .view(cancelButton)
            )
        }
        
        let contentStackView = UIStackView().then {
            $0.axis = .vertical
            
            $0.addStackViewItems(
                .view(textStackView),
                .customSpace(24),
                .view(buttonsStackView))
        }
        
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            
            $0.addStackViewItems(
                .view(UIImageView(image: #imageLiteral(resourceName: "default_browser_intro")).then {
                    $0.contentMode = .scaleAspectFit
                    $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                }),
                .view(contentStackView)
            )
        }
        
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(36)
        }
    }
}
