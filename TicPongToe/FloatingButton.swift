//
//  FloatingButton.swift
//  TicPongToe
//
//  Created by Nathan Lane on 10/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import UIKit

class FloatingButton: UIButton {

    private var floating_value:CGFloat = 9;
    private var original_position:CGFloat = 0.0;
    private var delay:CGFloat = 0.0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(notification:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        original_position = self.center.y;
    }
    
    public func AnimateButton() {
        
        UIView.animate(withDuration: 1.0, delay: TimeInterval(delay),
                       options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.center.y += self.floating_value;
        }, completion: {(complete: Bool) in
            self.center.y = self.original_position;
        })
    }
    
    public func setDelay(delay: CGFloat) {
        self.delay = delay;
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        AnimateButton();
    }

    public func setFloatingValue(value: CGFloat) {
        self.floating_value = value;
    }
}
