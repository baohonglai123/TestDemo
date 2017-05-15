//
//  ViewController.m
//  AirPlayDemo
//
//  Created by 包红来 on 2017/5/14.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "ViewController.h"
#import "BonjourClient.h"
#import "BonjourServer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clientStartAction:(id)sender {
    BonjourClient *client = [[BonjourClient alloc] init];
    [client startSearch];
}

- (IBAction)serviceStartAction:(id)sender {
    BonjourServer *server = [[BonjourServer alloc] init];
    [server publish];
}

@end
