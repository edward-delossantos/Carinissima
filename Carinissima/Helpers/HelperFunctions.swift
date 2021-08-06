//
//  HelperFunctions.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/28/21.
//

import Foundation
import JGProgressHUD

func convertToCurrency(_ number: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    return currencyFormatter.string(from: NSNumber(value: number))!
}

//show Hud notification
func showHudNotification(view: UIView, hud: JGProgressHUD, text: String, isError: Bool) {
    hud.textLabel.text = text
    hud.indicatorView = isError ? JGProgressHUDErrorIndicatorView() : JGProgressHUDSuccessIndicatorView()
    hud.show(in: view)
    hud.dismiss(afterDelay: 1.0)
}

