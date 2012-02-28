//
//  BIG5toGB.h
//  Holy Bible
//
//  Created by Will on 12/2/28.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface Big5ToGB : NSObject {
    unsigned char tbl[30000];
}
- (BOOL)readConvertedTbl;
- (NSString *)big5ToGB:(NSString *)big5;
@end
