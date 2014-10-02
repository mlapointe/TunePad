//
//  Song.h
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class SongSection;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * audioPath;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *songSection;
@end

@interface Song (CoreDataGeneratedAccessors)


- (void)addSongSectionObject:(SongSection *)value;
- (void)removeSongSectionObject:(SongSection *)value;
- (void)addSongSection:(NSSet *)values;
- (void)removeSongSection:(NSSet *)values;
@end
