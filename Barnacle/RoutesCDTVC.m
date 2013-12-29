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
#import "BarnacleRouteFetcher.h"
#import "RouteCreationViewController.h"
#import "RouteDetailViewController.h"

@interface RoutesCDTVC ()
@end

@implementation RoutesCDTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Routes";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushRouteCreationVC)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self useBarnalceDocument];
    }
}

- (void)pushRouteCreationVC {
    [self performSegueWithIdentifier:@"pushCreateRoute" sender:self];
}

- (void)useBarnalceDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Barnacle Routes"];
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
                          [self refresh];
    }
}



// TODO fix
- (IBAction)refresh
{    
    [self.refreshControl beginRefreshing];
    NSLog(@"refresh");
    // begin delete existing database
    NSManagedObjectContext * context = [self managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Route" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id basket in result)
        [context deleteObject:basket];
    // end delete existing database
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *routes = [BarnacleRouteFetcher latestRoutes];
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *route in routes) {
                [Route routeWithBarnacleInfo:route inManagedObjectConext:self.managedObjectContext];
            }
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
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:BARNACLE_STATUS ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // all routes
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:BARNACLE_STATUS cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Route"];
    
    Route *route = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = route.locstart;
    cell.detailTextLabel.text = route.locend;
    
    return cell;
}

NSIndexPath *indexPath = nil;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setRoute:"]) {
            Route *route = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setRoute:)]) {
                [segue.destinationViewController performSelector:@selector(setRoute:) withObject:route];
            }
        }
    }
}

@end
