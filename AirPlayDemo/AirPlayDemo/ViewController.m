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

@interface ViewController () {

}

@property(nonatomic,strong) BonjourServer *server;
@property(nonatomic,strong) BonjourClient *client;

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
    if (!_client) {
        _client = [[BonjourClient alloc] init];
    }
    [_client startMirror];
}

- (IBAction)serviceStartAction:(id)sender {
    self.server = [[BonjourServer alloc] init];
    [self.server publish];
}

@end
