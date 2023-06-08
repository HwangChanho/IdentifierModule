//
//  JDFDAUtil.m
//  JDFDAlib
//
//  Created by jiran_daniel on 2023/06/08.
//

#import "JDFDAUtil.h"

@implementation YourObjectiveCPPClass

- (void)checkStatusWithServiceCpp:(NSString*)service identifierOrPath:(NSString*)identifierOrPath {
    JDFDAUtil *swiftObject = [JDFDAUtil shared];
    [swiftObject checkStatusWithService:service identifierOrPath:identifierOrPath];
}

- (int)selectRowsForServiceWithServiceCpp:(NSString*)service identifierOrPath:(NSString*)identifierOrPath {
    JDFDAUtil *swiftObject = [JDFDAUtil shared];
    enum AuthValueStatus state = [swiftObject selectRowsForServiceWithService:service identifierOrPath:identifierOrPath];
    return 1;
}

- (void)showAlertCpp:(NSString*)text isHandle:(BOOL)isHandle {
    JDFDAUtil *swiftObject = [JDFDAUtil shared];
    [swiftObject showAlert:text isHandle:isHandle];
}

@end
