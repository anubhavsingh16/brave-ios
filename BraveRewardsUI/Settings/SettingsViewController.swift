/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import BraveRewards

class SettingsViewController: UIViewController {
  
  var settingsView: View {
    return view as! View // swiftlint:disable:this force_cast
  }
  
  let state: RewardsState
  let ledgerObserver: LedgerObserver
  
  init(state: RewardsState) {
    self.state = state
    self.ledgerObserver = LedgerObserver(ledger: state.ledger)
    super.init(nibName: nil, bundle: nil)
    self.state.ledger.add(self.ledgerObserver)
    setupLedgerObservers()
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError()
  }
  
  override func loadView() {
    view = View()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = Strings.SettingsTitle
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDone))
    
    preferredContentSize = CGSize(width: RewardsUX.preferredPanelSize.width, height: 750)
    
    state.ledger.updateAdsRewards()
    
    settingsView.do {
      $0.rewardsToggleSection.toggleSwitch.addTarget(self, action: #selector(rewardsSwitchValueChanged), for: .valueChanged)
      $0.grantsSections = state.ledger.pendingGrants.map {
        var type: SettingsGrantSectionView.GrantType
        if $0.type == "ads" {
          type = .ads(amount: BATValue(probi: $0.probi)?.displayString)
        } else {
          type = .ugp
        }
        let section = SettingsGrantSectionView(type: type)
        
        section.claimGrantTapped = { [weak self] section in
          guard let self = self else { return }
          let claimButton = section.claimGrantButton
          claimButton.isLoading = true
          claimButton.isEnabled = false
          
          self.ledgerObserver.grantClaimed = { [weak self] grant in
            guard let self = self, let grantAmount = BATValue(probi: grant.probi)?.displayString else { return }
            
            claimButton.isLoading = false
            claimButton.isEnabled = true
            
            let claimedVC = GrantClaimedViewController(
              grantAmount: grantAmount,
              expirationDate: Date(timeIntervalSince1970: TimeInterval(grant.expiryTime))
            )
            let container = PopoverNavigationController(rootViewController: claimedVC)
            self.present(container, animated: true)
          }
          
          if let grant = self.state.ledger.pendingGrants.first {
            self.state.ledger.solveGrantCaptch(withPromotionId: grant.promotionId, solution: "")
          }
        }
        return section
      }
      $0.walletSection.viewDetailsButton.addTarget(self, action: #selector(tappedWalletViewDetails), for: .touchUpInside)
      $0.adsSection.viewDetailsButton.addTarget(self, action: #selector(tappedAdsViewDetails), for: .touchUpInside)
      $0.adsSection.toggleSwitch.addTarget(self, action: #selector(adsToggleValueChanged), for: .valueChanged)
      $0.tipsSection.viewDetailsButton.addTarget(self, action: #selector(tappedTipsViewDetails), for: .touchUpInside)
      $0.autoContributeSection.viewDetailsButton.addTarget(self, action: #selector(tappedAutoContributeViewDetails), for: .touchUpInside)
      $0.autoContributeSection.toggleSwitch.addTarget(self, action: #selector(autoContributeToggleValueChanged), for: .valueChanged)
      
      let dollarString = state.ledger.dollarStringForBATAmount(state.ledger.balance?.total ?? 0) ?? ""
      $0.walletSection.setWalletBalance(state.ledger.balanceString, crypto: Strings.WalletBalanceType, dollarValue: dollarString)
      
      if !BraveAds.isCurrentRegionSupported() {
         $0.adsSection.status = .unsupportedRegion
      }
      $0.adsSection.toggleSwitch.isOn = state.ads.isEnabled
      $0.rewardsToggleSection.toggleSwitch.isOn = state.ledger.isEnabled
      $0.autoContributeSection.toggleSwitch.isOn = state.ledger.isAutoContributeEnabled
    }
    
    updateVisualStateOfSections(animated: false)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Not sure why this has to be set on the nav controller specifically instead of just this controller
    navigationController?.preferredContentSize = CGSize(width: RewardsUX.preferredPanelSize.width, height: 1000)
  }
  
  // MARK: -
  
  private func updateVisualStateOfSections(animated: Bool) {
    let ledger = state.ledger
    settingsView.do {
      $0.rewardsToggleSection.setRewardsEnabled(ledger.isEnabled, animated: animated)
      $0.adsSection.setSectionEnabled(
        ledger.isEnabled && state.ads.isEnabled,
        hidesToggle: !ledger.isEnabled,
        animated: animated
      )
      $0.autoContributeSection.setSectionEnabled(
        ledger.isEnabled && ledger.isAutoContributeEnabled,
        hidesToggle: !ledger.isEnabled,
        animated: animated
      )
      $0.tipsSection.setSectionEnabled(ledger.isEnabled, animated: animated)
    }
  }
  
  // MARK: - Actions
  
  @objc private func tappedDone() {
    dismiss(animated: true)
  }
  
  @objc private func tappedAdsViewDetails() {
    let controller = AdsDetailsViewController(state: state)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func tappedWalletViewDetails() {
    let controller = WalletDetailsViewController(state: state)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func tappedTipsViewDetails() {
    let controller = TipsDetailViewController(state: state)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func tappedAutoContributeViewDetails() {
    let controller = AutoContributeDetailViewController(state: state)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func rewardsSwitchValueChanged() {
    state.ledger.isEnabled = settingsView.rewardsToggleSection.toggleSwitch.isOn
    updateVisualStateOfSections(animated: true)
  }
  
  @objc private func adsToggleValueChanged() {
    state.ads.isEnabled = settingsView.adsSection.toggleSwitch.isOn
    updateVisualStateOfSections(animated: true)
  }
  
  @objc private func autoContributeToggleValueChanged() {
    state.ledger.isAutoContributeEnabled = settingsView.autoContributeSection.toggleSwitch.isOn
    updateVisualStateOfSections(animated: true)
  }
  
  func setupLedgerObservers() {
    ledgerObserver.fetchedBalance = { [weak self] in
      guard let self = self else { return }
      self.settingsView.walletSection.setWalletBalance(
        self.state.ledger.balanceString,
        crypto: Strings.WalletBalanceType,
        dollarValue: self.state.ledger.usdBalanceString
      )
    }
  }
}
