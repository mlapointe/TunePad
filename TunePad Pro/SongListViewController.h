//
//  MasterViewController.h
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SectionEditViewController;

#import <CoreData/CoreData.h>

@interface SongListViewController : UITableViewController

@property (strong, nonatomic) SectionEditViewController *detailViewController;

//@property (nonatomic, strong) UIManagedDocument *songDatabase;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *songList;

//@property (nonatomic, strong) UIBarButtonItem *addButton;
//@property (nonatomic, strong) UIBarButtonItem *backButton;





@end
