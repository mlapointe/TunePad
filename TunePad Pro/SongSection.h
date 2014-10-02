//
//  SongSection.h
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song;

@interface SongSection : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * chords;
@property (nonatomic, retain) NSString * lyrics;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) Song *fromSong;

@end
