//
//  EUExFile+search.h
//  EUExFileMgr
//
//  Created by Cerino on 15/9/10.
//  Copyright (c) 2015年 xll. All rights reserved.
//

#import "EUExFile.h"

@interface EUExFile (search)

typedef NS_OPTIONS(NSInteger, uexFileMgrSearchOption){
    uexFileMgrSearchNone          = 0,
    uexFileMgrSearchIncludingFolder = 1 << 0,
    uexFileMgrSearchExactly       = 1 << 1,
    uexFileMgrSearchRecursively   = 1 << 2
};




+(void)searchFilesByPath:(NSString *)realPath
                  option:(uexFileMgrSearchOption)option
                keywords:(NSArray*)keywords
                suffixes:(NSArray*)suffixes
              conpletion:(void (^)(BOOL isSuccess,NSArray * result))completion;
@end
