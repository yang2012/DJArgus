//
//  Compatible.m
//  Argus
//
//  Created by chris on 7/14/15.
//  Copyright (c) 2015 lynxchina. All rights reserved.
//

#import "Compatible.h"

double IPHONE_OS_MAIN_VERSION() {
    static double __iphone_os_main_version = 0.0;
    if (__iphone_os_main_version == 0.0) {
        NSString *sv = [[UIDevice currentDevice] systemVersion];
        NSScanner *sc = [[NSScanner alloc] initWithString:sv];
        if (![sc scanDouble:&__iphone_os_main_version])
            __iphone_os_main_version = -1.0;
    }
    return __iphone_os_main_version;
}


BOOL IPHONE_OS_7() {
    return IPHONE_OS_MAIN_VERSION() >= 7.0;
}

BOOL IPHONE_OS_SUPPORTMULTITASK() {
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
        return YES;
    } else {
        return NO;
    }
    
}