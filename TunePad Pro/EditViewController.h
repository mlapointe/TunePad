//
//  EditViewController.h
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "Song.h"
#import "SectionEditViewController.h"

#import "RecordView.h"

@interface EditViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL createNewSong;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Song *song;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)buttonHandler:(UIBarButtonItem *)sender;
- (IBAction)editButtonAction:(UIBarButtonItem *)sender;

@end
