//
//  SBTheTVDBConnection.h
//  Subler
//
//  Created by Damiano Galassi on 24/05/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBTheTVDBConnection : NSObject

@property (class, readonly) SBTheTVDBConnection *defaultManager;

@property (nonatomic, readonly) NSArray<NSString *> *languagues;

- (NSArray<NSDictionary *> *)fetchSeries:(NSString *)seriesName language:(NSString *)language;
- (nullable NSDictionary *)fetchSeriesInfo:(NSNumber *)seriesID language:(NSString *)language;
- (NSArray<NSDictionary *> *)fetchSeriesActors:(NSNumber *)seriesID language:(NSString *)language;
- (NSArray<NSDictionary *> *)fetchSeriesImages:(NSNumber *)seriesID type:(NSString *)type language:(NSString *)language;

- (NSArray<NSDictionary *> *)fetchEpisodes:(NSNumber *)seriesID season:(NSString *)season number:(NSString *)number language:(NSString *)language;
- (nullable NSDictionary *)fetchEpisodesInfo:(NSNumber *)episodeID language:(NSString *)language;

@end

NS_ASSUME_NONNULL_END

