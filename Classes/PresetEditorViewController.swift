//
//  PresetEditorViewController.swift
//  Subler
//
//  Created by Damiano Galassi on 29/08/17.
//

import Cocoa

class PresetEditorViewController: SBMovieViewController {

    let preset: MetadataPreset
    @IBOutlet weak var presetTitle: NSTextField!
    @IBOutlet weak var replaceArtworks: NSButton!
    @IBOutlet weak var replaceAnnotations: NSButton!

    override var nibName: NSNib.Name? {
        return "PresetEditorViewController"
    }

    init(preset: MetadataPreset) {
        self.preset = preset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.metadata = preset.metadata

        super.viewDidLoad()

        if #available(OSX 10.14, *) {} else {
            view.appearance = NSAppearance(named: .aqua)
        }
        presetTitle.stringValue = preset.title

        preset.changed = true
        replaceArtworks.state = preset.replaceArtworks == false ? .on : .off
        replaceAnnotations.state = preset.replaceAnnotations == false ? .on : .off
    }

    @IBAction func done(_ sender: Any) {
        dismiss(self)
    }

    @IBAction func setReplaceArtworksState(_ sender: NSButton) {
        preset.replaceArtworks = sender.state == .off ? true : false
    }

    @IBAction func setReplaceAnnotationsState(_ sender: NSButton) {
        preset.replaceAnnotations = sender.state == .off ? true : false
    }
}
