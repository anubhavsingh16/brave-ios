// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Shared
import BraveShared

private typealias IntroPrefs = Preferences.DefaultBrowserIntro

struct DefaultBrowserIntroManager {
    /// This function should be called when the app is initialized.
    /// It determines whether we should show default browser intro popup or not and sets corresponding preferences accordingly.
    /// Returns true if the popup should be shown.
    @discardableResult
    static func prepareAndShowIfNeeded(isNewUser: Bool, launchDate: Date = Date()) -> Bool {
        // Empty new user value means it is the first time this code is called after
        // the default intro callout was introduced. Afterwards it should be never nil.
        if IntroPrefs.isNewUser.value == nil {
            IntroPrefs.isNewUser.value = isNewUser
        }
        
        guard let isNewUser = IntroPrefs.isNewUser.value,
           !IntroPrefs.completed.value else {
            return false
        }
        
        IntroPrefs.appLaunchCount.value += 1
        
        if isNewUser {
            if IntroPrefs.appLaunchCount.value == 2 {
                let nextDateToShow = AppConstants.buildChannel.isPublic ? 5.days : 5.minutes
                
                IntroPrefs.nextShowDate.value =
                    Date(timeIntervalSinceNow: nextDateToShow)
                return true
            }
            
            if let nextShowDate = IntroPrefs.nextShowDate.value,
               launchDate > nextShowDate {
                IntroPrefs.completed.value = true
                IntroPrefs.nextShowDate.value = nil
                return true
            }
        } else {
            let appLaunchesWhenToShowIntro = [1, 2, 4, 8, 20]
            
            if appLaunchesWhenToShowIntro.contains(IntroPrefs.appLaunchCount.value) {
                return true
            }
            
            if IntroPrefs.appLaunchCount.value > appLaunchesWhenToShowIntro.max() ?? 20 {
                IntroPrefs.completed.value = true
            }
        }
        
        return false
    }
}
