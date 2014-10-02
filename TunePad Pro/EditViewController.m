//
//  EditViewController.m
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "SongListViewController.h"
#import "SongSection.h"


@interface EditViewController()



@property (strong, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (assign, nonatomic) int cellCount; //used to set order property of songSection
@property (assign, nonatomic) BOOL editing;
@property (assign, nonatomic) BOOL userCanceled;
@property (assign, nonatomic) BOOL recordViewOpen;
@property (strong, nonatomic) NSArray *defaultToolbarButtons;
@property (strong, nonatomic) NSArray *editToolbarButtons;
@property (strong, nonatomic) NSArray *recordToolbarButtons;
@property (strong, nonatomic) NSTimer *scrollTimer;
@property (assign, nonatomic) int scrollIncrement;
@property (strong, nonatomic) UISlider *autoScrollSlider;
@property (strong, nonatomic) RecordView *recordView;
@property (assign, nonatomic) BOOL isScrolling;
@property (strong, nonatomic) SongSection *sectionToCopy;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIBarButtonItem *actionButton;



@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSURL *soundFileURL;
@property (strong, nonatomic) NSTimer *recordTimer;
@property (strong, nonatomic) NSTimer *playbackTimer;

- (void) saveSong;
- (void) addSection:(NSString *)title;
- (NSArray *) getSongSections;
- (void) createToolBarButtons;
- (void) autoScrollTimerAction;
- (void) stopScrollTimerAutomatically;
- (IBAction)recordViewButtons:(UIButton *)sender;
- (void) recordTimerAction;
- (void) playbackTimerAction;
- (void) displayComposerSheet;

@end


@implementation EditViewController

//UIAlerts + UIViews
@synthesize recordView = _recordView;
@synthesize bottomBar = _bottomBar;

//Boolean Variables
@synthesize createNewSong = _createNewSong;
@synthesize userCanceled = _userCanceled;
@synthesize editing = _editing;
@synthesize recordViewOpen = _recordViewOpen;
@synthesize isScrolling = _isScrolling;


@synthesize managedObjectContext = _managedObjectContext;
@synthesize song = _song;
@synthesize cellCount = _cellCount;
@synthesize tableView = _tableView;
@synthesize sections = _sections;
@synthesize defaultToolbarButtons = _defaultToolbarButtons;
@synthesize editToolbarButtons = _editToolbarButtons;
@synthesize recordToolbarButtons = _recordToolbarButtons;
@synthesize editButton = _editButton;
@synthesize scrollTimer = _scrollTimer;
@synthesize scrollIncrement = _scrollIncrement;
@synthesize autoScrollSlider = _autoScrollSlider;
@synthesize sectionToCopy = _sectionToCopy;
@synthesize background = _background;
@synthesize actionButton = _actionButton;


// AVAudio

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;
@synthesize soundFileURL = _soundFileURL;
@synthesize recordTimer = _recordTimer;
@synthesize playbackTimer = _playbackTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    NSLog(@"initWithNibName called");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"EditView viewDidLoadCalled");
    
    if (self.createNewSong == YES) {
    
        //Create UIAlertView to ask for SongTitle
        UIAlertView *getTitleAlert = [[UIAlertView alloc] initWithTitle:@"New Song Title" message:@"What do you want to call your new song?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Write!", nil];
        
        [getTitleAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *titleText = [getTitleAlert textFieldAtIndex:0];
        titleText.clearButtonMode = UITextFieldViewModeWhileEditing; 
        titleText.keyboardType = UIKeyboardTypeAlphabet; 
        titleText.keyboardAppearance = UIKeyboardAppearanceAlert; 
        
        [getTitleAlert setTag:0];
        
        [getTitleAlert show];
        
        self.sections = [[NSMutableArray alloc] init];
        self.cellCount = 0;
    } else {
        
        NSLog(@"createNewSong = NO");
        self.navigationItem.title = self.song.title;
        //read passed detail item (self.song)
        self.sections = [[NSMutableArray alloc] initWithArray:[self getSongSections]];
        //NSLog(@"self.sections = %@", self.sections);
        [self.tableView reloadData];
        
    }
    
    //Configure boolean variables
    self.editing = NO;
    self.userCanceled = NO;
    self.recordViewOpen = NO;
    self.isScrolling = NO;
    
    
    //Configure TableView
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self.tableView setAllowsSelection:NO];
    
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.background = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [self.background setImage:[UIImage imageNamed:@"parchment.png"]];
    
    [self.tableView setBackgroundView:self.background];
    
    self.scrollIncrement = 0;
    
    
    //Configure Toolbar
    [self createToolBarButtons];
    [self.bottomBar setItems:self.defaultToolbarButtons animated:YES];
    [self.bottomBar setTintColor:[UIColor blackColor]];
    
    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];

    
    //Configure AVAudioRecorder
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *audioPathString;
    
    if(![self.song audioPath]){
        audioPathString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", [self.song title]]];
        
        [[self.recordView playButton] setEnabled:NO];
        
    }else{
        audioPathString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.song audioPath]]];
        
    }
    
    self.soundFileURL = [[NSURL alloc] initFileURLWithPath:audioPathString];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    audioSession.delegate = self;
    
    [audioSession setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    
    //self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:nil];
    //[self.audioPlayer prepareToPlay];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    //SAVE SONG!?
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if(!self.userCanceled)
        [self saveSong];
}

- (void) viewWillAppear:(BOOL)animated{
    
//    self.sections = [[NSMutableArray alloc] initWithArray:[self getSongSections]];
    
    //NSLog(@"Sections Array = %@", self.sections);
    [self.tableView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}







#pragma mark - Button Actions

- (void) createToolBarButtons{
    
    
    //CREATE array of default Toolbar items
    self.autoScrollSlider = [[UISlider alloc] init];
    [self.autoScrollSlider setMaximumValue:5];
    [self.autoScrollSlider setMinimumValue:1];
    UIBarButtonItem *sliderAsToolbarItem = [[UIBarButtonItem alloc] initWithCustomView:self.autoScrollSlider];
    [sliderAsToolbarItem setWidth:120.0];

    
    UIBarButtonItem * playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:@selector(buttonHandler:)];
    [playButton setTag:1];
    [playButton setStyle:UIBarButtonItemStyleBordered];
    if (!self.song.audioPath){
        [playButton setEnabled:NO];  //looks faded -> can't press
    }
    
    UIBarButtonItem *autoScroll = [[UIBarButtonItem alloc] initWithTitle:@"Scroll" style:UIBarButtonItemStyleBordered target:nil action:@selector(buttonHandler:)];
    [autoScroll setTag:2];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:@selector(buttonHandler:)];
    [actionButton setTag:3];
    self.actionButton = actionButton;
    
    self.defaultToolbarButtons = [[NSArray alloc] initWithObjects:playButton, autoScroll, sliderAsToolbarItem, flexibleSpace, actionButton, nil];
    
    
    //CREATE array of edit Toolbar items
    UIBarButtonItem *recordButton = [[UIBarButtonItem alloc] initWithTitle:@"Record" style:UIBarButtonItemStyleBordered target:nil action:@selector(buttonHandler:)];
    //add image "microphone_icon.jpeg"
    //NSLog([[NSBundle mainBundle] resourcePath]);
    [recordButton setTag:5];
    [recordButton setTintColor:[UIColor redColor]];

    UIBarButtonItem *editTitleButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit Title" style:UIBarButtonItemStyleBordered target:nil action:@selector(buttonHandler:)];
    [editTitleButton setTag:6];
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:@selector(buttonHandler:)];
    [trashButton setStyle:UIBarButtonItemStyleBordered];
    [trashButton setTag:4];
    
    UIBarButtonItem *addSectionButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Section" style:UIBarButtonItemStyleBordered target:nil action:@selector(buttonHandler:)];
    [addSectionButton setTag:0];
    [addSectionButton setTintColor:[UIColor blueColor]];
    
    self.editToolbarButtons = [[NSArray alloc] initWithObjects:recordButton, editTitleButton, flexibleSpace, trashButton, addSectionButton,nil];
    
    
    //CREATE Record Button Toolbar
    self.recordToolbarButtons = [[NSArray alloc] initWithObjects:recordButton, flexibleSpace, autoScroll, sliderAsToolbarItem, nil];
    
}

- (IBAction)buttonHandler:(UIBarButtonItem *)sender{
    
    //ADD Section
    if(sender.tag == 0){
        UIActionSheet *addSection = [[UIActionSheet alloc] initWithTitle:@"Add Section" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Intro", @"Verse", @"PreChorus", @"Chorus", @"Bridge", @"Outro", nil];
        
        [addSection setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [addSection setTag:1];
        [addSection showFromToolbar:self.bottomBar];
    }
    
    //Play recording button
    if(sender.tag == 1){
        
        if(!self.audioPlayer.playing){
            //Reconfigure into a stop button
         
            NSError *error;
            
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:&error];
            
            self.audioPlayer.delegate = self;
            
            if(error)
                NSLog(@"AudioPlayer Error: %@", [error localizedDescription]);
            else{
                [self.audioPlayer play];
                [self.actionButton setEnabled:NO];
                [sender setTintColor:[UIColor redColor]];

            }
        }else{
            
            //Reconfigure into Play button
            
            [self.audioPlayer stop];
            [self.actionButton setEnabled:YES];
            [sender setTintColor:[UIColor blackColor]];
            
        }

        
    }
    
    //AutoScroll start/Stop
    if(sender.tag == 2){
        NSLog(@"AutoScroll pressed");

        if(sender.title == @"Scroll"){
            self.scrollIncrement = self.tableView.contentOffset.y;

            float i = self.autoScrollSlider.value;
            NSLog(@"UISlider Value = %f", i);

            
            self.scrollTimer = [[NSTimer alloc] init];
            self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(autoScrollTimerAction) userInfo: nil repeats:YES];
            
            [self.scrollTimer fire];
            self.isScrolling = YES;
            NSLog(@"ScrollTimer thread fire");
            
            
            [sender setTitle:@"Stop Scroll"];
            [sender setTintColor:[UIColor redColor]];
        } else {
            self.isScrolling = NO;
            
            [sender setTitle:@"Scroll"];
            [sender setTintColor:NULL];
            [self.scrollTimer invalidate];
            NSLog(@"ScrollTimer thread invalidated");
        }
        
    }
    
    //ACTION/SHARE Button
    if(sender.tag == 3){
        
        [self displayComposerSheet];
    }
    
    //DELETE Button
    if(sender.tag == 4){
        //Prompt - Are You Sure?
        UIActionSheet *deleteAction = [[UIActionSheet alloc] initWithTitle:@"Are you sure? \n This action will be permanent." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Song" otherButtonTitles:nil];
        
        [deleteAction setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [deleteAction setTag:0];
        [deleteAction showFromToolbar:self.bottomBar];
    }
    
    //record button
    if(sender.tag == 5){
        
        NSLog(@"Record button pressed");
        
        if([self.song audioPath])
            NSLog(@"Song file exists at: %@", [self.song audioPath]);
        
        //Open custom record view
        //https://github.com/kwylez/CustomUIASView/tree/master/CustomUIASView
        
        
        if(!self.recordViewOpen){
            self.recordViewOpen = YES;
            [self.tableView setEditing:NO animated:YES];
            [sender setTitle:@"Save"];
    
            CGRect recordFrame = CGRectMake(0, self.view.bounds.size.height - (self.bottomBar.bounds.size.height+72), 320, 72);
            self.recordView = [[RecordView alloc] initWithFrame:recordFrame];
            self.recordView.frame = CGRectMake(0, 460-self.bottomBar.bounds.size.height, 320, 72); //off bottom toolBar
            
            //Setup RecordView Buttons
            [[self.recordView playButton] addTarget:self action:@selector(recordViewButtons:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [[self.recordView recordButton] addTarget:self action:@selector(recordViewButtons:) forControlEvents:UIControlEventTouchUpInside];
            
            [[self.navigationController navigationBar] setUserInteractionEnabled:NO];
            [[self.navigationController navigationBar] setAlpha:.4];
            

            [self.bottomBar removeFromSuperview];
            [self.view addSubview:self.recordView];
            [self.view addSubview:self.bottomBar];

            [UIView animateWithDuration:.5 
                    animations:^{

                        self.recordView.frame = CGRectMake(0, self.view.bounds.size.height - (self.bottomBar.bounds.size.height+72), 320, 72);
                    }
                    completion:^(BOOL finished) {
                        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height- self.recordView.frame.size.height)];
                    }
             ];
            
            [self.bottomBar setItems:self.recordToolbarButtons animated:YES];
            
            
            
            
        }else{
            [UIView animateWithDuration:1 
                    animations:^{
                        self.recordView.frame = CGRectMake(0, 500, 320, 72);
                }
             completion:^(BOOL finished) {
                 [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height+ self.recordView.frame.size.height)];
             }];
            
            if(self.isScrolling){
                [self stopScrollTimerAutomatically];
            }
            
            [sender setTitle:@"Record"];
            [[self.navigationController navigationBar] setAlpha:1];
            [[self.navigationController navigationBar] setUserInteractionEnabled:YES];
            [self.recordView removeFromSuperview];
            
            [self.bottomBar setItems:self.editToolbarButtons animated:YES];
            [self.tableView setEditing:YES animated:YES];
            self.recordViewOpen = NO;
        }
    
        
    }
    
    
    //Edit Title
    if(sender.tag == 6){
        
        UIAlertView *editTitleAlert = [[UIAlertView alloc] initWithTitle:@"Edit Song Title" message:@"What do you want to call your song?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Save", nil];
        
        [editTitleAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *titleText = [editTitleAlert textFieldAtIndex:0];
        [titleText setText:[self.song title]];
        titleText.clearButtonMode = UITextFieldViewModeWhileEditing; 
        titleText.keyboardType = UIKeyboardTypeAlphabet; 
        titleText.keyboardAppearance = UIKeyboardAppearanceAlert; 
        
        [editTitleAlert setTag:1];
        
        [editTitleAlert show];
        
        
    }
    
    
    
}

- (IBAction)editButtonAction:(UIBarButtonItem *)sender{
    
    if (!self.editing){
        self.editing = YES;
        [self.tableView setEditing:YES animated:YES];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [sender setStyle:UIBarButtonItemStyleDone];
        [sender setTitle:@"Done"];
        [sender setTintColor:[UIColor blueColor]];
        
        [self.bottomBar setItems:self.editToolbarButtons animated:YES];        
        
        [self.background setAlpha:.6];
        
        
    }else{
        self.editing = NO;
        [self.tableView setEditing:NO animated:YES];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [sender setStyle:UIBarButtonItemStylePlain];
        [sender setTitle:@"Edit"];
        [sender setTintColor:[UIColor blackColor]];
        
        if(self.song.audioPath){
            [[self.defaultToolbarButtons objectAtIndex:0] setEnabled:YES];
        }
        
        [self.bottomBar setItems:self.defaultToolbarButtons animated:YES];
        
        [self.background setAlpha:1];
        
        
        
    }
    
}


- (IBAction)recordViewButtons:(UIButton *)sender{
    
    //Play Button
    if(sender.tag == 0){
        NSLog(@"RecordView Play Button Pressed");
        
        if(!self.audioRecorder.recording && !self.audioPlayer.playing){
            
            
            NSError *error;
            
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:&error];
            
            self.audioPlayer.delegate = self;
            
            
            self.playbackTimer = [[NSTimer alloc] init];
            self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(playbackTimerAction) userInfo: nil repeats:YES];
            
            
            
            if(error)
                NSLog(@"AudioPlayer Error: %@", [error localizedDescription]);
            else{
                
                [self.audioPlayer play];
                [self.playbackTimer fire];
                
                
                //Create stop button
                [[self.recordView playButton] setBackgroundImage:[UIImage imageNamed:@"matteStopButton.png"]forState: UIControlStateNormal];
           
                [[self.recordView recordButton] setUserInteractionEnabled:NO];
                [[self.recordView recordButton] setAlpha:.6];
              
            }

            
            
        }else if(self.audioPlayer.playing){
            
            [self.audioPlayer stop];
            [self.playbackTimer invalidate];
            
             [[self.recordView recordButton] setUserInteractionEnabled:YES];
             [[self.recordView recordButton] setAlpha:1];
            
            [[self.recordView playButton] setBackgroundImage:[UIImage imageNamed:@"green-play-button.png"]forState: UIControlStateNormal];
            
        }
        
        
    }
    
    //Record Button
    if(sender.tag == 1){
        NSLog(@"RecordView Record Button pressed");
        
        if(self.audioRecorder.recording){
            [self.audioRecorder stop];
            [self.recordTimer invalidate];
            
            
            [[self.recordView playButton] setUserInteractionEnabled:YES];
            [[self.recordView playButton] setAlpha:1];
            
            [[self.recordView recordLabel] setText:@"Rec"];
            [[self.recordView recordLabel] setTextColor:[UIColor whiteColor]];
    
            
            self.audioRecorder = nil;
            
            [sender setImage:[UIImage imageWithContentsOfFile:@"microphone_icon.jpg"] forState:UIControlStateNormal];
            
            //[[AVAudioSession sharedInstance] setActive:NO error:nil];
            
            
            //[self.song setAudioPath:[NSString stringWithFormat:@"%@.caf", [self.song title]]];
            
            [self.song setAudioPath:[self.soundFileURL lastPathComponent]];
            
        }else{
            
            //other - http://www.techotopia.com/index.php/Recording_Audio_on_an_iPhone_with_AVAudioRecorder_(iOS_4)
            NSDictionary *recordSettings = [NSDictionary 
                                            dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:AVAudioQualityMin],
                                            AVEncoderAudioQualityKey,
                                            [NSNumber numberWithInt:16], 
                                            AVEncoderBitRateKey,
                                            [NSNumber numberWithInt: 2], 
                                            AVNumberOfChannelsKey,
                                            [NSNumber numberWithFloat:44100.0], 
                                            AVSampleRateKey,
                                            nil];
            
            //Apple
//            NSDictionary *recordSettings =
//                [[NSDictionary alloc] initWithObjectsAndKeys:
//                    [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
//                    [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
//                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
//                    [NSNumber numberWithInt: AVAudioQualityMax],
//                        AVEncoderAudioQualityKey,
//                    nil];
            
            NSError *error = nil;
            
            self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:&error];
            
            self.audioRecorder.delegate = self;
            
            self.recordTimer = [[NSTimer alloc] init];
            self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(recordTimerAction) userInfo: nil repeats:YES];
            
            
            BOOL xz;
            
            if(error){
                NSLog(@"audioRecorder error: %@", [error localizedDescription]);
            }else{
                xz = [self.audioRecorder prepareToRecord];
            }
            
            
            NSLog(@"prepareToRecord: %i", xz);
            
            
            BOOL temp = [self.audioRecorder record];
            [self.recordTimer fire];
            
            NSLog(@"Record: %i", temp);
            
            [sender setImage:[UIImage imageWithContentsOfFile:@"matteStopButton.png"] forState:UIControlStateHighlighted];
            
            
            [[self.recordView recordLabel] setText:@"Recording..."];
            [[self.recordView recordLabel] setTextColor:[UIColor redColor]];
            
            
            [[self.recordView playButton] setUserInteractionEnabled:NO];
            [[self.recordView playButton] setAlpha:.8];
                                                                    
            [[self.recordView progressView] setProgress:0 animated:YES];
            
        }
        
        
        
    }
    
    //Stop button
    if(sender.tag ==2){
        
        
        
        
        
    }
    
    
    
}







# pragma mark - ActionSheets + UIAlerts

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //deleteAction
    if (actionSheet.tag == 0){
        
        //Confirm Delete
        if(buttonIndex == 0){
            NSLog(@"Confirm Delete button clicked");
            
            //DELETE SONG!
            [self.managedObjectContext deleteObject:self.song];
                
            // managed object context saved upon viewWillDisappear
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    //AddNewSection
    if (actionSheet.tag == 1){
        
        //Intro
        if(buttonIndex == 0){
            NSLog(@"Intro button pressed");
            [self addSection:@"Intro"];

        }
        
        //Verse
        if(buttonIndex == 1){
            NSLog(@"Verse button pressed");
            [self addSection:@"Verse"];
        }
        
        //PreChorus
        if(buttonIndex == 2){
            NSLog(@"PreChorus button pressed");
            [self addSection:@"PreChorus"];
        }
        
        //Chorus
        if(buttonIndex == 3){
            NSLog(@"Chorus button pressed");
            [self addSection:@"Chorus"];
        }
        
        //Bridge
        if(buttonIndex == 4){
            NSLog(@"Bridge button pressed");
            [self addSection:@"Bridge"];
        }
        
        //Outro
        if(buttonIndex == 5){
            NSLog(@"Outro button pressed");
            [self addSection:@"Outro"];
        }
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    
    
    for(int i = 0; i < self.sections.count-1; i++){
        
                
        if([[[self.sections objectAtIndex:i] sectionTitle] isEqualToString:buttonTitle]){
            
            UIAlertView *copyView = [[UIAlertView alloc] initWithTitle:@"Copy Text" 
                                                               message:[NSString stringWithFormat:@"Would you like to copy anytihng from the first %@?", buttonTitle] 
                                                                delegate:self 
                                                                cancelButtonTitle:@"No" 
                                                                otherButtonTitles: @"Copy Chords", @"Copy Lyrics", @"Copy Both", nil];
            
            self.sectionToCopy = [self.sections objectAtIndex:i];
            [copyView setTag:2];
            [copyView show];
            break;
        }
    }
    
    
}

- (void) alertView: (UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Title for New Song
    if(alertView.tag == 0){
        //cancelButton?
        if (buttonIndex == 0){
            
            NSLog(@"Cancel Button Pressed");
            self.userCanceled = YES;
            [self.navigationController popViewControllerAnimated:YES];        
        }
        
        //Write! Button
        if (buttonIndex == 1){
            NSLog(@"Write! button pressed");
            
            //SetTitleLabel
            self.navigationItem.title = [alertView textFieldAtIndex:0].text;
            [self saveSong];
            
            [self editButtonAction:self.editButton];

            //Start autosaving NStimer?
            
        }
    }
    
    //Edit Title of existing Song
    if(alertView.tag == 1){
        if(buttonIndex ==1){
            
            self.navigationItem.title = [alertView textFieldAtIndex:0].text;
            [self.song setTitle:[alertView textFieldAtIndex:0].text];
            
        }
        
        
    }
    
    if(alertView.tag == 2){
        
        NSLog(@"Button at index: %i", buttonIndex);
        
        //Copy chords
        if(buttonIndex == 1){
            NSLog(@"Clicked Copy Chords");
            
            [[self.sections lastObject] setChords:self.sectionToCopy.chords];
        }
        
        //Copy Lyrics
        if (buttonIndex == 2){
            NSLog(@"Clicked Copy Lyrics");
            
            [[self.sections lastObject] setLyrics:self.sectionToCopy.lyrics];
        }
        
        //Copy both
        if(buttonIndex == 3){
            NSLog(@"Clicked Copy Both");
            
            [[self.sections lastObject] setChords:self.sectionToCopy.chords];
            [[self.sections lastObject] setLyrics:self.sectionToCopy.lyrics];
        }
        
        [self.tableView reloadData];
        
        
    }
}

//AlertView Text validation - You must input a title!
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(alertView.tag != 2){
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        if( [inputText length] > 0 )
            return YES;
        else
            return NO;
        
    }
    
    return YES;
}









# pragma mark - DB Actions

-(void) saveSong {
    
    //New Song instance
    if(!self.song){
        if(self.managedObjectContext == nil){ 
            NSLog(@"No managedObjectcontext in editViewController!");
        }
        
        self.song = (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
        
        NSLog(@"Song Created");
        
        [self.song setTitle:self.navigationItem.title];
        [self.song setTimeStamp:[NSDate date]];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"No managedObjetContext! \n Error: %@", error);
        }
    
        self.createNewSong = NO;
        
    }else{
        
        //Update existing song
        NSLog(@"Song Exists. Updating Song");
        
        for (int i =0; i<self.sections.count; i++){
            [[self.sections objectAtIndex:i] setOrder:[[NSNumber alloc] initWithInt:i]];
        }
        
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
}


- (void)addSection:(NSString *)title{
    
    if(self.managedObjectContext == nil){ 
        NSLog(@"No managedObjectcontext in editViewController!");
    }
    
    SongSection *section = (SongSection *)[NSEntityDescription insertNewObjectForEntityForName:@"SongSection" inManagedObjectContext:self.managedObjectContext];
    
    [section setSectionTitle:title];
    self.cellCount++;
    [section setOrder:[[NSNumber alloc] initWithInt:self.cellCount]];
    [section setFromSong:self.song];
    [self.song addSongSectionObject:section];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"No managedObjectContext! \n Error: %@", error);
    }
    
    
    [self.sections addObject:section];
    
    //NSLog(@"Section Created: %@", section);
    
    //NSLog(@"Sections Array after add: %@", self.sections);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.sections.count-1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.sections.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (NSArray *) getSongSections {
    
    NSSet *sections = [self.song songSection];
    NSLog(@"Number of Song Sections: %i", [sections count]);
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *descriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    return [sections sortedArrayUsingDescriptors:descriptorArray];
    
}





# pragma mark - TableView Stuff

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"EditViewController tableview:cellforRowAtIndexPath: called");
    
    
    
    NSString *CellIdentifier = @"songSectionCell";

    
    // Dequeue or create a new cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    SongSection *cellSection = [self.sections objectAtIndex:indexPath.row];
    
    UILabel *cellTitle = (UILabel *)[cell viewWithTag:1];
    UILabel *cellChords = (UILabel *)[cell viewWithTag:2];
    UITextView *cellLyrics = (UITextView*)[cell viewWithTag:3];
    
    cellTitle.text = [cellSection sectionTitle];
    cellChords.text = [cellSection chords];
    cellLyrics.text = [cellSection lyrics];
    
    //[cellLyrics resignFirstResponder];
    [cellLyrics setUserInteractionEnabled: NO];
    
    CGRect frame = cellLyrics.frame;
    frame.size.height = cellLyrics.contentSize.height;
    cellLyrics.frame = frame;
    
//    NSLog(@"Sections Array = %@", self.sections);
//    NSLog(@"Section at index 0: %@", [self.sections objectAtIndex:0]);
    
    return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1; //just want one section!
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //NSLog(@"Number of rows to make: %d",[self.sections count] );
    
    return [self.sections count];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"CommitEditingStyle Called");
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        NSLog(@"UITableViewCellEditingStyleDelete = TRUE");
        
        //Delete managed object @ given index path
        NSManagedObject *sectionToDelete = [self.sections objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:sectionToDelete];
        
        //Update the array and table view
        [self.sections removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        //Commit the change
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]){
            
            //Handle the error
        }
    }
    
    if (editingStyle == UITableViewCellEditingStyleNone){
        
        NSLog(@"UITableViewCellEditingStyleNone = TRUE");
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return self.editing;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
      toIndexPath:(NSIndexPath *)toIndexPath 
{
    SongSection *cell = [self.sections objectAtIndex:fromIndexPath.row];
    [self.sections removeObject:cell];
    [self.sections insertObject:cell atIndex:toIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *lyrics = [[self.sections objectAtIndex:indexPath.row] lyrics];
    
    CGSize size = [lyrics sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Regular" size:16.0] constrainedToSize:CGSizeMake(320, 1000) lineBreakMode:UILineBreakModeWordWrap];
    
    
    
    //NSLog(@"CGsize.height = %f", size.height);
    
    
    
    if (size.height+60 <= 120){
        //NSLog(@"returned default height");
        return 120;
    } 
    
    //NSLog(@"Returned custom Height: %f",size.height+25);
    return size.height+60;
}   


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(self.isScrolling){
        self.scrollIncrement = scrollView.contentOffset.y;
    }
    
}





# pragma mark - AVAudioRecorder/Player Delegate Methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self.playbackTimer invalidate];
    
     [[self.recordView recordButton] setUserInteractionEnabled:YES];
     [[self.recordView recordButton] setAlpha:1];
    
    [[self.recordView playButton] setBackgroundImage:[UIImage imageNamed:@"green-play-button.png"]forState: UIControlStateNormal];
    
    if(!self.actionButton.isEnabled){
        [self.actionButton setEnabled:YES];
        
        UIBarButtonItem *playButton;
        
        for(int i = 0; i< self.defaultToolbarButtons.count; i++){
            UIBarButtonItem *button = [self.defaultToolbarButtons objectAtIndex:i];
            
            if(button.tag == 1){
                playButton = button;
                break;
            }
        }
        
        [playButton setTintColor:[UIColor blackColor]];
        
    }
    
}



-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    NSLog(@"Decode Error occurred");
}


-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    //[[self.recordView playButton] setUserInteractionEnabled:YES];
    
}

-(void)audioRecorderEncodeErrorDidOccur: (AVAudioRecorder *)recorder error:(NSError *)error{
    
    NSLog(@"Encode Error occurred");
}


#pragma mark - Email Sharing

-(void) displayComposerSheet {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSData *myData = [NSData dataWithContentsOfURL:self.soundFileURL];
    [picker addAttachmentData:myData mimeType:@"audio/caf" fileName:[NSString stringWithFormat:@"%@.caf", self.song.title]];
    
    NSString *emailBody = [NSString stringWithFormat:@"\n%@ \n\n", self.song.title];
    
    for (int i=0; i< self.sections.count; i++){
        
        emailBody = [emailBody stringByAppendingString:@"**"];
        emailBody = [emailBody stringByAppendingString:[[self.sections objectAtIndex:i] sectionTitle]];
        emailBody = [emailBody stringByAppendingString:@"**"];
        emailBody = [emailBody stringByAppendingString:@"    "];
        
        if([[self.sections objectAtIndex:i] chords]){
            emailBody = [emailBody stringByAppendingString:[[self.sections objectAtIndex:i] chords]];
        }
        
        emailBody = [emailBody stringByAppendingString:@"\n"];

        if([[self.sections objectAtIndex:i] lyrics]){
            emailBody = [emailBody stringByAppendingString:[[self.sections objectAtIndex:i] lyrics]];
        }
        emailBody = [emailBody stringByAppendingString:@"\n\n\n"];

        
    }
    
    
    [picker setMessageBody:emailBody isHTML:NO];
    
    [[picker navigationBar] setTintColor:[UIColor blackColor]];
    
    [self presentModalViewController:picker animated:YES];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if(result == MFMailComposeResultSent){ 
        NSLog(@" Result sent");
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}


# pragma mark - OTHER

- (void) autoScrollTimerAction{
    
    CGRect rect = CGRectMake(self.tableView.frame.origin.x, self.scrollIncrement, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    [self.tableView scrollRectToVisible:rect animated:YES];
    
    self.scrollIncrement += self.autoScrollSlider.value; 
    
    //Stop Scrolling Automatically at Bottom of UITableView
    if(self.scrollIncrement > self.tableView.contentSize.height - self.tableView.frame.size.height){

        [self stopScrollTimerAutomatically];
    }
}

- (void) stopScrollTimerAutomatically{
    
    self.isScrolling = NO;
    UIBarButtonItem *button;
    
    for(int i = 0; i< self.defaultToolbarButtons.count; i++){
        if([(UIBarButtonItem *)[self.defaultToolbarButtons objectAtIndex:i] tag] == 2){
            button = [self.defaultToolbarButtons objectAtIndex:i];
            break;
        }
    }
    
    [button setTitle:@"Scroll"];
    [button setTintColor:NULL];
    [self.scrollTimer invalidate];
    NSLog(@"ScrollTimer thread invalidated automatically");
    
}


- (void) recordTimerAction {
    
    int seconds = [self.audioRecorder currentTime];
    
    int min = seconds/60;
    int sec = seconds%60;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setMinimumIntegerDigits:2];
    [formatter setMaximumIntegerDigits:2];
    
    [self.recordView timer].text = [NSString stringWithFormat:@"%@:%@", 
                                    [formatter stringFromNumber:[NSNumber numberWithInt:min]],[formatter stringFromNumber:[NSNumber numberWithInt:sec]]];
    
}

- (void) playbackTimerAction {
    float seconds = [self.audioPlayer currentTime];
    
    int min = seconds/60;
    int sec = (int)seconds%60;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setMinimumIntegerDigits:2];
    [formatter setMaximumIntegerDigits:2];
    
    [self.recordView timer].text = [NSString stringWithFormat:@"%@:%@", 
                                    [formatter stringFromNumber:[NSNumber numberWithInt:min]],[formatter stringFromNumber:[NSNumber numberWithInt:sec]]];
    
    
    
    float dur = [self.audioPlayer duration];
    
    [[self.recordView progressView] setProgress: seconds/dur animated:YES];
    
    
    
}




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
  
    if([[segue identifier] isEqualToString:@"editSection"]){
        
        NSLog(@"editSection segue called");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SongSection *selectedObject = [self.sections objectAtIndex:indexPath.row];
        SectionEditViewController *controller = [segue destinationViewController];
        [controller setSection:selectedObject];
        [controller setManagedObjectContext:self.managedObjectContext];
    }
    
    
}



@end
