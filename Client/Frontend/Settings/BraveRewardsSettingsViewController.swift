// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Static
import Shared
import BraveShared
import BraveRewards
import BraveUI
import DeviceCheck

class BraveRewardsSettingsViewController: TableViewController {
    
    let rewards: BraveRewards
    let legacyWallet: BraveLedger?
    
    init(_ rewards: BraveRewards, legacyWallet: BraveLedger?) {
        self.rewards = rewards
        self.legacyWallet = legacyWallet
        
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.braveRewardsTitle
        
        dataSource.sections = [
            .init(
                rows: [
                    Row(text: "Brave Rewards",
                        detailText: "Support content creators and publishers automatically by enabling Brave Private Ads. Brave Private Ads are privacy-respecting ads that give back to content creators.",
                        accessory: .switchToggle(value: rewards.isEnabled, { [unowned self] isOn in
                            self.rewards.isEnabled = isOn
                        }),
                        cellClass: MultilineSubtitleCell.self)
                ],
                footer: .title("Brave Rewards payouts are temporarily unavailable on this device. Transfer your existing wallet funds to a desktop wallet to keep your tokens.")
            )
        ]
        
        if let legacyWallet = legacyWallet {
            legacyWallet.fetchBalance({ [weak self] balance in
                guard let self = self, let balance = balance else { return }
                if balance.total > 0 {
                    self.dataSource.sections += [
                        .init(
                            header: .title("Wallet Transfer"),
                            rows: [
                                Row(text: "Legacy Wallet Transfer", selection: { [unowned self] in
                                    guard let legacyWallet = self.legacyWallet else { return }
                                    let controller = WalletTransferViewController(legacyWallet: legacyWallet)
                                    let container = UINavigationController(rootViewController: controller)
                                    self.present(container, animated: true)
                                }, image: UIImage(imageLiteralResourceName: "rewards-qr-code").template)
                            ]
                        )
                    ]
                }
            })
        }
        
        if rewards.ledger.isWalletCreated {
            dataSource.sections += [
                Section(rows: [
                    Row(text: Strings.RewardsInternals.title, selection: {
                        let controller = RewardsInternalsViewController(rewards: self.rewards)
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, accessory: .disclosureIndicator)
                ])
            ]
        }
    }
}
