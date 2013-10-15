//
//  RoutesCDTVC.m
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RoutesCDTVC.h"
#import "Route.h"
#import "Route+Barnacle.h"

@interface RoutesCDTVC ()
@end

@implementation RoutesCDTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [super viewDidLoad];
    self.title = @"Routes";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        NSLog(@"will appear");
    if (!self.managedObjectContext) [self useDemoDocument];
    
}

- (void)useDemoDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Demo Document"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}


// TODO fix
- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
//        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            NSDictionary *route1 = @{
                                     @"key" : @"abc",
                                     @"locstart" : @"SF",
                                     @"locend" : @"LA",
                                     };
            NSDictionary *route2 = @{
                                     @"key" : @"ab3234c",
                                     @"locstart" : @"SF",
                                     @"locend" : @"LV",
                                     };
            
            NSLog(@"refresh");
            NSLog([self.managedObjectContext description]);
            [Route routeWithBarnacleInfo:route1 inManagedObjectConext:self.managedObjectContext];
            [Route routeWithBarnacleInfo:route2 inManagedObjectConext:self.managedObjectContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
 }



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Route"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // all routes
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Route"];
    
    Route *route = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(route.key);
    NSLog(route.locstart);
    cell.textLabel.text = route.locstart;
    cell.detailTextLabel.text = route.locend;
    
    return cell;
}

@end
