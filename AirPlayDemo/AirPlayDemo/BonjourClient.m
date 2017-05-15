//
//  BonjourClient.m
//  AirPlayDemo
//
//  Created by 包红来 on 2017/5/14.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "BonjourClient.h"
@interface BonjourClient() {
    NSNetServiceBrowser *_serviceBrowser;
}
@end

@implementation BonjourClient

-(instancetype) init {
    if (self = [super init]) {
        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
        __weak id weakSelf = self;
        _serviceBrowser.delegate = weakSelf;
    }
    return self;
}

- (void) startSearch {
    [_serviceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];
    NSLog(@"service start search");

}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    NSLog(@"didFindService..");
}

@end
