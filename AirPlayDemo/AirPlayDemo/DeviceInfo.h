//
//  DeviceInfo.h
//  AirSpeaker
//
//  Created by Clément Vasseur on 12/22/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <Foundation/NSString.h>

@interface DeviceInfo : NSObject {

}

+ (NSString *)getSysInfoByName:(char *)typeSpecifier;
+ (NSString *)platform;
+ (NSData *)deviceId;
+ (NSString *)deviceIdString;
+ (NSString *)deviceIdWithSep:(NSString *)sep;

@end
