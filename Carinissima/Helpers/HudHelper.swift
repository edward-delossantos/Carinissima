//
//  HudHelper.swift
//  Carinissima
//
//  Created by Edward de los Santos on 8/5/21.
//

import Foundation
import JGProgressHUD

//show HUD notification
public func showNotification(view: UIView, hud: JGProgressHUD, text: String, isError: Bool) {
    hud.textLabel.text = text
    hud.indicatorView = isError ? JGProgressHUDErrorIndicatorView() : JGProgressHUDSuccessIndicatorView()
    hud.show(in: view)
    hud.dismiss(afterDelay: 2.0)
}
