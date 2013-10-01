//
//  LTRListsViewController.m
//  lister
//
//  Created by Geoff Cornwall on 7/31/13.
//  Copyright (c) 2013 Geoff Cornwall. All rights reserved.
//

#import "LTRListsViewController.h"
#import "LTRItemsViewController.h"
#import "LTRAddEditListViewController.h"
#import "LTRSettingsViewController.h"
#import "LTRLoginViewController.h"
#import "LTRHTTPClient.h"
#import "LTRUtility.h"

@interface LTRListsViewController ()

@end

@implementation LTRListsViewController

- (void)viewDidLoad {
    [TestFlight passCheckpoint:@"LISTS_VIEW"];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    _listSegControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"My Lists", @"All Lists", nil]];
    [_listSegControl addTarget:self action:@selector(listSegControlChanged:)forControlEvents:UIControlEventValueChanged];
    [_listSegControl setSelectedSegmentIndex:0];
    _listSegControl.frame = CGRectMake(0,0,175,30);
    self.navigationItem.titleView = _listSegControl;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                              target:self action:@selector(addList:)];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                             initWithTitle:@"Logout" style:UIBarButtonSystemItemAction
//                                             target:self action:@selector(logout:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain
                                             target:self action:@selector(displaySettings:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    _randomColor = [LTRUtility randomColor];
    self.tableView.backgroundColor = _randomColor;
    [self refresh:nil];
}

- (void)refresh:(id)sender {
    _apiToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiToken"];
    _userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    _username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

    if (_apiToken == nil) {
        [self displayLogin];
    }
    else if (_listSegControl.selectedSegmentIndex == 0) {
        [[LTRHTTPClient sharedInstance] getLists:nil
                                      withUserId:_userId
                                    onCompletion:^(BOOL success, NSDictionary *json) {
            NSMutableArray *workingListArray = [NSMutableArray new];
            for (NSDictionary *dict in json) {
                LTRList *list = [[LTRList alloc] initWithData:dict];
                if (list == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An API error occured" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [self logout:nil];
                }
                else {
                    [workingListArray addObject:list];
                }
            }
            
            NSSortDescriptor *dateSortor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:dateSortor];
            _lists = [workingListArray sortedArrayUsingDescriptors:sortDescriptors];
            [self.tableView reloadData];
        }];
    }
    else {
        [[LTRHTTPClient sharedInstance] getLists:nil withUserId:nil onCompletion:^(BOOL success, NSDictionary *json) {
            NSMutableArray *workingListArray = [NSMutableArray new];
            for (NSDictionary *dict in json) {
                LTRList *list = [[LTRList alloc] initWithData:dict];
                if (list == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An API error occured" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [self logout:nil];
                }
                else {
                    if (![list.username isEqualToString:_username]) {
                        [workingListArray addObject:list];
                    }
                }
            }
            
            NSSortDescriptor *dateSortor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:dateSortor];
            _lists = [workingListArray sortedArrayUsingDescriptors:sortDescriptors];
            [self.tableView reloadData];
        }];
    }

}

- (void)addList:(id)sender {
    LTRAddEditListViewController *addListViewController = [[LTRAddEditListViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addListViewController];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)displayLogin {
    LTRLoginViewController *loginViewController = [[LTRLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	[self presentViewController:navController animated:NO completion:nil];
}

- (void)displaySettings:(id)sender {
    LTRSettingsViewController *settingsViewController = [[LTRSettingsViewController alloc] initWithDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"apiToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _apiToken = nil;
    
    [self refresh:nil];
}

- (void)listSegControlChanged:(id)sender {
    if (_listSegControl.selectedSegmentIndex == 0) {
        _listSegControl.selectedSegmentIndex = 0;
    }
    else if (_listSegControl.selectedSegmentIndex == 1) {
        _listSegControl.selectedSegmentIndex = 1;
    }
    
    _randomColor = [LTRUtility randomColor];
    self.view.backgroundColor = _randomColor;
    [self refresh:nil];
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_lists count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    LTRList *list = [_lists objectAtIndex:indexPath.row];
    cell.textLabel.text = list.listName;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_lists count] > 0) {
        LTRList *list = [_lists objectAtIndex:indexPath.row];
        if ([list.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]) {
            return UITableViewCellEditingStyleDelete;
        }
        return UITableViewCellEditingStyleNone;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LTRList *list = [_lists objectAtIndex:indexPath.row];
        [[LTRHTTPClient sharedInstance] deleteList:list.listId onCompletion:^(BOOL success, NSDictionary *json) {
            [self refresh:nil];
        }];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LTRList *list = [_lists objectAtIndex:indexPath.row];
    LTRItemsViewController *itemsViewController = [[LTRItemsViewController alloc] initWithList:list];
    self.navigationItem.title = @"";
    [self.navigationController pushViewController:itemsViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
