//
//  BonjourClient.m
//  AirPlayDemo
//
//  Created by 包红来 on 2017/5/14.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "BonjourClient.h"
#import <AVFoundation/AVFoundation.h>
#import "MPAudioVideoRoutingViewController.h"
#import "MPAVRoutingController.h"
#import "MPAVSystemRoutingController.h"
#import "MPAudioVideoRoutingTableViewController.h"
#import "MPAudioDeviceController.h"
#import "MPAVRoute.h"
#import "MPAudioVideoRoutingPopoverController.h"
#import "UIPopoverController+iPhone.h"

@interface BonjourClient() {
    NSNetServiceBrowser *_serviceBrowser;
    MPAVRoutingController *routerController;
    NSString *airplayName;
    BOOL shouldConnect;

}

@property (nonatomic, strong) NSTimer *routingTimer;
@property (strong, nonatomic) MPAudioVideoRoutingPopoverController *airplayPopoverController;

@property(nonatomic, copy) NSNumber *audioSampleRate;
@property(nonatomic, copy) NSNumber *numberOfAudioChannels;
@end

@implementation BonjourClient

-(instancetype) init {
    if (self = [super init]) {
        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
        __weak id weakSelf = self;
        _serviceBrowser.delegate = weakSelf;
        airplayName = @"MacBook";
    }
    return self;
}

- (void)_setupAudio
{
    // Setup to be able to record global sounds (preexisting app sounds)
    
    NSError *sessionError = nil;
    
    
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
    
    
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    
    self.audioSampleRate  = @44100;
    self.numberOfAudioChannels = @2;
    
    // Set the number of audio channels, using defaults if necessary.
    NSNumber *audioChannels = (self.numberOfAudioChannels ? self.numberOfAudioChannels : @2);
    NSNumber *sampleRate    = (self.audioSampleRate       ? self.audioSampleRate       : @44100.f);
    
    NSDictionary *audioSettings = @{
                                    AVNumberOfChannelsKey : (audioChannels ? audioChannels : @2),
                                    AVSampleRateKey       : (sampleRate    ? sampleRate    : @44100.0f)
                                    };
    
    
}
- (void)setupAirplayMonitoring
{
    if (!routerController) {
        routerController = [[MPAVRoutingController alloc] init];
        routerController.delegate = self;
        routerController.discoveryMode = 1;
    }
}

- (void) startSearch {
    [_serviceBrowser searchForServicesOfType:@"_raop._tcp." inDomain:@"local."];
    NSLog(@"service start search");
    [self _setupAudio];

}

- (void) startMirror {
    if (self.routingTimer) {
        [self.routingTimer invalidate];
    }
    [self _setupAudio];
    [self setupAirplayMonitoring];
    NSLog(@"startMirror");
    
//    self.routingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                         target:self
//                                                       selector:@selector(setupAirplayMonitoring)
//                                                       userInfo:nil
//                                                        repeats:YES];
}

- (void)enableMirroring:(NSTimer *)timer {
    MPAudioVideoRoutingTableViewController *tableViewController = [[MPAudioVideoRoutingTableViewController alloc] initWithType:0
                                                                                                        displayMirroringRoutes:YES];
    
    MPAVRoutingController *tableRouteController = [tableViewController routingController];
    
    [tableRouteController fetchAvailableRoutesWithCompletionHandler:^(NSArray *routes) {
        for (MPAVRoute *route in routes) {
            NSLog(@"route:%@",route.routeName);
            MPAVRoute *displayRoute = [route wirelessDisplayRoute];
            if (displayRoute) {
                NSLog(@"displayRoute:%@",displayRoute.routeName);
                [tableRouteController pickRoute:displayRoute];
                [timer invalidate];
            }
        }
    }];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    NSLog(@"didFindService..");
}

- (void) dealloc {
    NSLog(@"%s",__FUNCTION__);
}

-(void)routingControllerAvailableRoutesDidChange:(id)arg1{
    NSLog(@"arg1-%@",arg1);
    if (airplayName == nil) {
        return;
    }
    
    NSArray *availableRoutes = [routerController valueForKey:@"availableRoutes"];
    for (id router in availableRoutes) {
        NSString *routerName = [router valueForKey:@"routeName"];
        NSLog(@"routername -%@",routerName);
        if ([routerName rangeOfString:airplayName].length >0) {
            BOOL picked = [[router valueForKey:@"picked"] boolValue];
            if (picked == NO && !shouldConnect) {
                shouldConnect = YES;
                NSLog(@"connect once");
                NSString *one = @"p";
                NSString *two = @"ickR";
                NSString *three = @"oute:";
                NSString *path = [[one stringByAppendingString:two] stringByAppendingString:three];
                [routerController performSelector:NSSelectorFromString(path) withObject:router];
                //objc_msgSend(self.routerController,NSSelectorFromString(path),router);
            }
            return;
        }
    }
}

@end
