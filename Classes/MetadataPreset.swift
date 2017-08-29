//
//  MetadataPreset.swift
//  Subler
//
//  Created by Damiano Galassi on 21/08/2017.
//

import Foundation

@objc(SBMetadataPreset) class MetadataPreset: NSObject, Preset {

    var pathExtension: String {
        return "sbpreset2"
    }
    var title: String
    @objc let metadata: MP42Metadata
    @objc var replaceArtworks: Bool
    @objc var replaceAnnotations: Bool

    let version: Int
    var changed: Bool

    @objc init(title: String, metadata: MP42Metadata, replaceArtworks: Bool, replaceAnnotations: Bool) {
        self.title = title
        self.metadata = metadata
        self.replaceArtworks = replaceArtworks
        self.replaceAnnotations = replaceAnnotations
        self.changed = true
        self.version = 2
    }

    // MARK: NSCoding

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(metadata, forKey: "metadata")
        aCoder.encode(version, forKey: "version")
        aCoder.encode(replaceArtworks, forKey: "replaceArtworks")
        aCoder.encode(replaceAnnotations, forKey: "replaceAnnotations")
    }

    required init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(of: NSString.self, forKey: "title") as String?,
            let metadata = aDecoder.decodeObject(of: MP42Metadata.self, forKey: "metadata") as MP42Metadata?
            else { return nil }

        let version = aDecoder.decodeInteger(forKey: "version")
        let replaceArtworks = aDecoder.decodeBool(forKey: "replaceArtworks")
        let replaceAnnotations = aDecoder.decodeBool(forKey: "replaceAnnotations")

        self.title = title
        self.metadata = metadata
        self.replaceArtworks = replaceArtworks
        self.replaceAnnotations = replaceAnnotations
        self.version = version
        self.changed = false
    }

    static var supportsSecureCoding: Bool { return true }

    // MARK: NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        return MetadataPreset(title: title, metadata: metadata, replaceArtworks: replaceArtworks, replaceAnnotations: replaceAnnotations)
    }
}
