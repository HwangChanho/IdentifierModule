//
//  JDFDAUtil.m
//  JDFDAlib
//
//  Created by jiran_daniel on 2023/06/08.
//
#import <Foundation/Foundation.h>

#import "FDAlib-Swift.h"
#import "JDFDAUtil.hpp"

void checkFDAStatusOfApp(const char * _bundleID) {
    JDFDAUtil *swiftUtil = [JDFDAUtil shared];
    
    NSString* bundleID = [[NSString alloc] initWithUTF8String:_bundleID];
    
    [swiftUtil checkFDAStatusOfAppFrom:bundleID];
}
