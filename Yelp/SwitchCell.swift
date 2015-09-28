//
//  SwitchCell.swift
//  Yelp
//
//  Created by Xian on 9/26/15.
//  Copyright © 2015. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(SwitchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        print("switchValueChanged to \(onSwitch.on) for '\(switchLabel.text)'")
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

}
