//
//  EUExFile+search.h
//  EUExFileMgr
//
//  Created by Cerino on 15/9/10.
//  Copyright (c) 2015年 xll. All rights reserved.
//

#import "EUExFile.h"

@interface EUExFile (search)

typedef NS_OPTIONS(NSInteger, uexFilrMgrSearchOption){
    uexFilrMgrSearchNone          = 0,
    uexFilrMgrSearchIncludingFolder = 1 << 0,
    uexFilrMgrSearchExactly       = 1 << 1,
    uexFilrMgrSearchRecursively   = 1 << 2
};




+(void)searchFilesByPath:(NSString *)realPath
                  option:(uexFilrMgrSearchOption)option
                keywords:(NSArray*)keywords
                suffixes:(NSArray*)suffixes
              conpletion:(void (^)(BOOL isSuccess,NSArray * result))completion;
@end
