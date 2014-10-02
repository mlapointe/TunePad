//
//  DetailViewController.m
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionEditViewController.h"
#import "EditViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SectionEditViewController ()

@property (assign, nonatomic) CGRect originalFrame;

@end

@implementation SectionEditViewController

@synthesize section = _section;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize chords = _chords;
@synthesize lyrics = _lyrics;
@synthesize recordAudio = _recordAudio;
@synthesize toolbar = _toolbar;

@synthesize originalFrame = _originalFrame;


#pragma mark - Managing the detail item



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (self.section) {
        NSLog(@"there is a valid songSection");
        NSLog(@"%@", self.section);
        
        self.navigationItem.title = [self.section sectionTitle];
        
        self.chords.text = [self.section chords];
        self.lyrics.text = [self.section lyrics];
    }else{
        NSLog(@"Error: No Valid SongSecton item passed!");
    }
    
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [background setImage:[UIImage imageNamed:@"parchment.png"]];
    
    [self.view insertSubview:background atIndex:0];
    
    
    self.chords.delegate = self;
    self.lyrics.delegate = self;
    
    //Create Lyrics UITableView Border
    [[self.lyrics layer] setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [[self.lyrics layer] setBorderWidth:2.3];
    [[self.lyrics layer] setCornerRadius:10];
    [self.lyrics setBackgroundColor:[UIColor clearColor]];
    
    [self.toolbar setTintColor:[UIColor blackColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
     NSLog(@"Chords = %@", self.chords.text);
    
    
    [self.section setChords:self.chords.text];
    [self.section setLyrics:self.lyrics.text];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

//Close Keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

//limit text field size ~ doesn't work for copy/paste
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int length = [textField.text length] ;
    if (length >= 40 && ![string isEqualToString:@""]) {
        textField.text = [textField.text substringToIndex:40];
        return NO;
    }
    return YES;
}

-(IBAction)backgroundTouched:(id)sender
{
    [self.lyrics resignFirstResponder];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect viewFrame = self.lyrics.frame;
    self.originalFrame = self.lyrics.frame;
    viewFrame.size.height -= (kbSize.height - 44);
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationBeginsFromCurrentState:YES];

    //[UIView setAnimationDuration:0.3];
    [self.lyrics setFrame:viewFrame];
    //[UIView commitAnimations];
    

}

- (void) keyboardWillBeHidden:(NSNotification *)aNotification {
    
    self.lyrics.frame = self.originalFrame;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



@end
