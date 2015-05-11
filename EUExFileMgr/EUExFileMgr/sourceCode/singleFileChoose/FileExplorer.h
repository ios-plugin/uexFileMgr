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
@interface FileExplorer : NSObject <FileSelectorDelegate>{
	EUExFileMgr *euexObj;
}
-(void)openWithEuex:(EUExFileMgr *)euexObj_ rootPath:(NSString *)inPath;
@end
