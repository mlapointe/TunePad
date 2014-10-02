//
//  MasterViewController.m
//  TunePad Pro
//
//  Created by Mike Lapointe on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SongListViewController.h"
#import "AppDelegate.h"

#import "SectionEditViewController.h"
#import "EditViewController.h"
#import "Song.h"

@interface SongListViewController ()
- (void) setupFetch;
//- (void) useDocument;

@end

@implementation SongListViewController

@synthesize detailViewController = _detailViewController;
//@synthesize songDatabase = _songDatabase;  //UImanagedDocument
@synthesize managedObjectContext;
@synthesize songList;

//@synthesize addButton = _addButton;


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

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
    self.detailViewController = (SectionEditViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"My Songs";
    
 
    
    //Grab appDelegate managedObjectContext
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    
    [self setupFetch];
    
    
//    [self.tableView setBackgroundColor:[UIColor clearColor]];
//    UIImageView *background = [[UIImageView alloc] initWithFrame:self.tableView.frame];
//    [background setImage:[UIImage imageNamed:@"parchment.png"]];
    
//    [self.tableView setBackgroundView:background];
    
     [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupFetch];
    [self.tableView reloadData];
    
}

-(void) setupFetch {
    
    NSLog(@"setupFetch Called");
    
    //Set Up Fetch Request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor , nil];
    [request setSortDescriptors:sortDescriptors];
    
    //Fetched Results Controller
    //NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"songCache"];
    //NSError *error2 =nil;
    //BOOL success = [controller performFetch:&error2];
    
    
    //Execute the request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil){
        //Handle the error
    }
    
    //set ViewController's song array
    [self setSongList:mutableFetchResults];
    
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

# pragma - TableView Management

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"tableview:cellforRowAtIndexPath: called");
    
    // A date formatter for the time stamp.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    static NSString *CellIdentifier = @"SongCell";
    
    // Dequeue or create a new cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Song *newSong = (Song *)[songList objectAtIndex:indexPath.row];
    
    //test
//    if([songList objectAtIndex:0] != Nil){
//        NSLog(@"Object Exists");
//    }
    
    cell.textLabel.text = [newSong title];

    cell.detailTextLabel.text = [dateFormatter stringFromDate:[newSong timeStamp]];
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1; //just want one section!
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    

    return [songList count];
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        //Delete managed object @ given index path
        NSManagedObject *songToDelete = [songList objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:songToDelete];
        
        //Update the array and table view
        [songList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        //Commit the change
        NSError *error = nil;
        if (![managedObjectContext save:&error]){
            
            //Handle the error
        }
    }
    
}





# pragma - Stanford lecture stuff
//
//- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
//{
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
//    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
//    
//    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                        managedObjectContext:self.songDatabase.managedObjectContext
//                                                                          sectionNameKeyPath:nil
//                                                                                   cacheName:nil];
//}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"newSong"]){
        
        EditViewController *controller = segue.destinationViewController;
        [controller setCreateNewSong:YES];
        [controller setManagedObjectContext:self.managedObjectContext];
        
    }
    
    if ([[segue identifier] isEqualToString:@"showSong"]) {
        
        NSLog(@"showSong segue called");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Song *selectedObject = [self.songList objectAtIndex:indexPath.row];
        //[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setSong:selectedObject];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}


@end
