//
//  TabBarViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/4/14.
//
//  Initial view controller for the application. Contains a log child view
//  as well as the summary view

#import "TabBarViewController.h"


@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up the tab bar items
    UITabBarItem *log = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *summary = [self.tabBar.items objectAtIndex:1];
    
    [log setTitle:@"Log"];
    [summary setTitle:@"Summary"];
    
    // set up the images for the tab items
    log.selectedImage = [[UIImage imageNamed:@"logSelected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
     log.image = [[UIImage imageNamed:@"log.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    summary.selectedImage = [[UIImage imageNamed:@"summarySelected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    summary.image = [[UIImage imageNamed:@"summary.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
