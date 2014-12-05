//
//  TabBarViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/4/14.
//
//

#import "TabBarViewController.h"


@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITabBarItem *log = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *summary = [self.tabBar.items objectAtIndex:1];
    [log setTitle:@"Log"];
    [summary setTitle:@"Summary"];
    //[self.tabBar setBackgroundColor:[UIColor colorWithRed:0.11 green:0.671 blue:0.843 alpha:1]]; /*#1cabd7*/
     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
