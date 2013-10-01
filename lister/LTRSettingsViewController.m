//
//  LTRSettingsViewController.m
//  lister
//
//  Created by Geoff Cornwall on 10/1/13.
//  Copyright (c) 2013 Geoff Cornwall. All rights reserved.
//

#import "LTRSettingsViewController.h"
#import "LTRCreditsViewController.h"

@interface LTRSettingsViewController ()

@end

@implementation LTRSettingsViewController

- (id)initWithDelegate:(id)delegate {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [TestFlight passCheckpoint:@"SETTINGS_VIEW"];
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Done" style:UIBarButtonItemStyleBordered
                                              target:self action:@selector(clickDone:)];
    
    // load table data
    self.dataSourceArray = [NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Credits", @"label",
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Logout", @"label",
                                 nil],
                            nil];

}

- (void)clickDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([self.dataSourceArray count] / 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
    static NSString *cellIdentifier = @"CellIdentifier";
    cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    // do not try this [objectAtIndex:indexPath.section] at home
    NSString *cellText = [[self.dataSourceArray objectAtIndex:indexPath.section] valueForKey:@"label"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = cellText;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSLog(@"Credits");
        LTRCreditsViewController *creditsViewController = [[LTRCreditsViewController alloc] init];
        [self.navigationController pushViewController:creditsViewController animated:YES];
    }
    else if (indexPath.section == 1) {
        NSLog(@"Logout");
        [_delegate logout:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
