//
//  JDFDAUtil.h
//  JDFDAlib
//
//  Created by jiran_daniel on 2023/06/08.
//

#ifndef JDFDAUtil_h
#define JDFDAUtil_h

#import <Foundation/Foundation.h>
#import "JDFDAlib-Swift.h"

@class JDFDAUtil;

@interface YourObjectiveCPPClass : NSObject

- (void)checkStatusWithServiceCpp:(NSString*)service identifierOrPath:(NSString*)identifierOrPath;
- (int)selectRowsForServiceWithServiceCpp:(NSString*)service identifierOrPath:(NSString*)identifierOrPath;
- (void)showAlertCpp:(NSString*)text isHandle:(BOOL)isHandle;

@end

#endif
