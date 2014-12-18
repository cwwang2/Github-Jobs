//
//  PCSViewController.m
//  Github Jobs
//
//  Created by Bruce Wang on 2014/9/2.
//  Copyright (c) 2014年 Bruce Wang. All rights reserved.
//

#import "PCSViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PCSViewController ()

@property (nonatomic, strong) NSArray *jobs;

@end

@implementation PCSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.jobs[indexPath.row] [@"title"];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *endpoint = [[NSBundle bundleForClass:[self class]] infoDictionary][@"GithubJobsEndpoint"];
    
    NSURL *url = [NSURL URLWithString: [ endpoint stringByAppendingString: @"?description=ios&locatioin=NY"]];
    NSURLSessionDataTask *jobTask = [[NSURLSession sharedSession] dataTaskWithURL:
    url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An error occured"
                                                                message: error.localizedDescription
                                                               delegate: nil
                                                      cancelButtonTitle: @"Dismiss"
                                                      otherButtonTitles: nil];
                [alert show];
                return;
            };
            NSError *jsonError = nil;
            self.jobs = [NSJSONSerialization JSONObjectWithData: data options: 0 error:&jsonError];
            [self.tableView reloadData];
        });
        
        [SVProgressHUD showSuccessWithStatus: [NSString stringWithFormat: @"%lu jobs fetched", (unsigned long)[self.jobs count]]];
    }];
    [SVProgressHUD showWithStatus:@"Fetching jobs..."];
    [jobTask resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *jobUrl = [NSURL URLWithString: self.jobs[indexPath.row][@"url"]];
    [[UIApplication sharedApplication] openURL:jobUrl];
}

@end
