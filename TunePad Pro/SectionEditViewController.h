//
//  DetailViewController.h
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongSection.h"

@interface SectionEditViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) SongSection *section;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UITextField *chords;
@property (strong, nonatomic) IBOutlet UITextView *lyrics;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *recordAudio;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end
