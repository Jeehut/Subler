//
//  SBQueueAction.m
//  Subler
//
//  Created by Damiano Galassi on 12/03/14.
//
//

#import "SBQueueAction.h"

#import "SBQueueItem.h"
#import "MetadataImporter.h"

#import <MP42Foundation/MP42File.h>
#import <MP42Foundation/MP42FileImporter.h>
#import <MP42Foundation/MP42Image.h>
#import <MP42Foundation/MP42Utilities.h>

@implementation SBQueueSubtitlesAction

- (NSArray *)loadSubtitles:(NSURL *)url {
    NSError *outError;
    NSMutableArray *tracksArray = [[NSMutableArray alloc] init];
    NSArray *directory = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[url URLByDeletingLastPathComponent]
                                                       includingPropertiesForKeys:nil
                                                                          options:NSDirectoryEnumerationSkipsSubdirectoryDescendants |
                                                                                  NSDirectoryEnumerationSkipsHiddenFiles |
                                                                                  NSDirectoryEnumerationSkipsPackageDescendants
                                                                            error:nil];

    for (NSURL *dirUrl in directory) {
        if ([[dirUrl pathExtension] caseInsensitiveCompare:@"srt"] == NSOrderedSame) {
            NSComparisonResult result;
            NSString *movieFilename = [[url URLByDeletingPathExtension] lastPathComponent];
            NSString *subtitleFilename = [[dirUrl URLByDeletingPathExtension] lastPathComponent];
            NSRange range = { 0, [movieFilename length] };

            if ([movieFilename length] <= [subtitleFilename length]) {
                result = [subtitleFilename compare:movieFilename options:NSCaseInsensitiveSearch range:range];

                if (result == NSOrderedSame) {
                    MP42FileImporter *fileImporter = [[[MP42FileImporter alloc] initWithURL:dirUrl
                                                                                      error:&outError] autorelease];

                    for (MP42Track *track in fileImporter.tracks) {
                        [tracksArray addObject:track];
                    }
                }
            }
        }
    }

    return [tracksArray autorelease];
}

- (void)runAction:(SBQueueItem *)item {
    // Search for external subtitles files
    NSArray *subtitles = [self loadSubtitles:item.URL];
    for (MP42SubtitleTrack *subTrack in subtitles) {
        [item.mp4File addTrack:subTrack];
    }
}

- (NSString *)description {
    return @"Load Subtitles";
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

@end

@implementation SBQueueMetadataAction

- (instancetype)init {
    self = [super init];
    if (self) {
        _language = [MetadataImporter defaultMovieLanguage];
        _movieProvider = @"TheMovieDB";
        _tvShowProvider = @"TheTVDB";
    }
    return self;
}

- (instancetype)initWithLanguage:(NSString *)language movieProvider:(NSString *)movieProvider tvShowProvider:(NSString *)tvShowProvider {
    self = [self init];
    if (self) {
        _language = language;
        _movieProvider = movieProvider;
        _tvShowProvider = tvShowProvider;
    }
    return self;
}

- (MP42Image *)loadArtwork:(NSURL *)url {
    NSData *artworkData = [MetadataImporter downloadDataFromURL:url withCachePolicy:SBDefaultPolicy];
    if (artworkData && [artworkData length]) {
        MP42Image *artwork = [[MP42Image alloc] initWithData:artworkData type:MP42_ART_JPEG];
        if (artwork != nil) {
            return [artwork autorelease];
        }
    }

    return nil;
}

- (MP42Metadata *)searchMetadataForFile:(NSURL *)url {
    id currentSearcher = nil;
    MP42Metadata *metadata = nil;

    // Parse FileName and search for metadata
    NSDictionary *parsed = [MetadataImporter parseFilename:[url lastPathComponent]];
    NSString *type = (NSString *)[parsed valueForKey:@"type"];
    if ([@"movie" isEqualToString:type]) {
		currentSearcher = [MetadataImporter importerForProvider:_movieProvider];
		NSString *language = [MetadataImporter defaultMovieLanguage];
		NSArray *results = [currentSearcher searchMovie:[parsed valueForKey:@"title"] language:language];
        if ([results count])
			metadata = [currentSearcher loadMovieMetadata:[results objectAtIndex:0] language:language];
    } else if ([@"tv" isEqualToString:type]) {
		currentSearcher = [MetadataImporter importerForProvider:_tvShowProvider];
		NSString *language = [MetadataImporter defaultTVLanguage];
		NSArray *results = [currentSearcher searchTVSeries:[parsed valueForKey:@"seriesName"]
                                                  language:language seasonNum:[parsed valueForKey:@"seasonNum"]
                                                episodeNum:[parsed valueForKey:@"episodeNum"]];
        if ([results count])
			metadata = [currentSearcher loadTVMetadata:[results objectAtIndex:0] language:language];
    }

    if (metadata.artworkThumbURLs && [metadata.artworkThumbURLs count]) {
        NSURL *artworkURL = nil;
        if ([type isEqualToString:@"movie"]) {
            artworkURL = [metadata.artworkFullsizeURLs objectAtIndex:0];
        } else if ([type isEqualToString:@"tv"]) {
            if ([metadata.artworkFullsizeURLs count] > 1) {
                int i = 0;
                for (NSString *artworkProviderName in metadata.artworkProviderNames) {
                    NSArray *a = [artworkProviderName componentsSeparatedByString:@"|"];
                    if ([a count] > 1 && ![[a objectAtIndex:1] isEqualToString:@"episode"]) {
                        artworkURL = [metadata.artworkFullsizeURLs objectAtIndex:i];
                        break;
                    }
                    i++;
                }
            } else {
                artworkURL = [metadata.artworkFullsizeURLs objectAtIndex:0];
            }
        }

        MP42Image *artwork = [self loadArtwork:artworkURL];

        if (artwork)
            [metadata.artworks addObject:artwork];
    }

    return metadata;
}

- (void)runAction:(SBQueueItem *)item {
    // Search for metadata
    MP42Metadata *metadata = [self searchMetadataForFile:item.URL];

    for (MP42Track *track in [item.mp4File tracksWithMediaType:MP42MediaTypeVideo])
        if ([track isKindOfClass:[MP42VideoTrack class]]) {
            MP42VideoTrack *videoTrack = (MP42VideoTrack *)track;
            int hdVideo = isHdVideo((uint64_t)videoTrack.trackWidth, (uint64_t)videoTrack.trackHeight);

            if (hdVideo)
                [metadata setTag:@(hdVideo) forKey:@"HD Video"];
        }

    [[item.mp4File metadata] mergeMetadata:metadata];
}

- (NSString *)description {
    return @"Search Metadata";
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

@end

@implementation SBQueueSetAction

- (id)initWithSet:(MP42Metadata *)set {
    self = [super init];
    if (self) {
        _set = [set retain];
    }
    return self;
}

- (void)runAction:(SBQueueItem *)item {
    [item.mp4File.metadata mergeMetadata:_set];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Apply %@ Set", _set.presetName];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _set = [[coder decodeObjectForKey:@"SBQueueActionSet"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_set forKey:@"SBQueueActionSet"];
}

- (void)dealloc {
    [_set release];
    [super dealloc];
}

@end

@implementation SBQueueOrganizeGroupsAction

- (void)runAction:(SBQueueItem *)item {
    [item.mp4File organizeAlternateGroups];
}

- (NSString *)description {
    return @"Organize Groups";
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}


@end
