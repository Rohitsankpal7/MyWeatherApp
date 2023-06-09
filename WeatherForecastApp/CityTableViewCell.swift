//
//  CityTableViewCell.swift
//  WeatherForecastApp
//
//  Created by Rohit Sankpal on 08/06/23.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    @IBOutlet weak var lblCityName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
