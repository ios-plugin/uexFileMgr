//
//  FileExplorer.h
//  WebKitCorePlam
//
//  Created by AppCan on 11-9-20.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileSelectorViewController.h"
@class EUExFileMgr;
@interface FileExplorer : NSObject <FileSelectorDelegate>

- (instancetype)initWithEUExObj:(EUExFileMgr *)euexObj rootPath:(NSString *)path;
- (void)presentControllerWithCompletion:(void (^)(NSString *selectedPath))completion;


@end
