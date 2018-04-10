//
//  ViewController.swift
//  SimpleHUD
//
//  Created by Gopal Krishna Reddy Thotli on 20/03/18.
//  Copyright © 2018 Gopal Krishna Reddy Thotli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func showLightHorizontal(_ sender: Any) {
        showHUD(style:.light, alignment: .horizontal, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                SHUD.updateHUDText("Fetching Projects...")
                Delay.by(time: 3) {
                    SHUD.updateHUDText("Fetching Managers...")
                    Delay.by(time: 3) {
                        SHUD.updateHUDText("Fetching Leads...")
                        Delay.by(time: 3) {
                            SHUD.updateHUDText("Fetching Roles...")
                            Delay.by(time: 3) {
                                self.hideHUD()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func showLightVertical(_ sender: Any) {
        showHUD(style:.light, alignment: .vertical, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                self.hideHUD()
            }
        }
    }
    
    @IBAction func showDarkHorizontal(_ sender: Any) {
        showHUD(style:.dark, alignment: .horizontal, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                self.hideHUD()
            }
        }
    }
    
    @IBAction func showDarkVertical(_ sender: Any) {
        showHUD(style:.dark, alignment: .vertical, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                self.hideHUD()
            }
        }
    }
    
    @IBAction func hideWithSuccess(_ sender: Any) {
        showHUD(alignment: .vertical, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                self.hideHUD(success: true, text: "Done")
            }
        }
    }
    
    @IBAction func hideWithFailure(_ sender: Any) {
        showHUD(style:.light, alignment: .vertical, type: .loading, text: "Fetching data...") {
            Delay.by(time: 3) {
                self.hideHUD(success: false, text: "Failed")
            }
        }
    }
    
    @IBAction func hideWithInfo(_ sender: Any) {
        showHUD(type: .info, text: "Good Morning") {
            Delay.by(time: 3) {
                self.hideHUD()
            }
        }
    }

}

