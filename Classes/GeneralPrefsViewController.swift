//
//  GeneralPrefsViewController.swift
//  Subler
//
//  Created by Damiano Galassi on 06/02/2018.
//

import Cocoa
import MP42Foundation

class GeneralPrefsViewController: NSViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("General", comment: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var nibName: NSNib.Name? {
        return "GeneralPrefsViewController"
    }

    @IBAction func clearRecentSearches(_ sender: Any) {
        MetadataSearchController.clearRecentSearches()
    }

    @IBAction func deleteCachedMetadata(_ sender: Any) {
        MetadataSearchController.deleteCachedMetadata()
    }

    @IBAction func updateRatingsCountry(_ sender: Any) {
        MP42Ratings.defaultManager.updateCountry()
    }

    @objc dynamic var ratingsCountries: [String] { return MP42Ratings.defaultManager.ratingsCountries }

}
