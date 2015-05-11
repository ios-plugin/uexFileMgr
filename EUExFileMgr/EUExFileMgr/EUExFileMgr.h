//
//  EUExFileMgr.h
//  AppCan
//
//  Created by AppCan on 11-9-8.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExBase.h"
#import "FileExplorer.h"

#define UEXFILEMGR_OBJECT_SIZE		10	

#define F_FILE_EXPLORER_PATH		@"fileExplorerPath"
#define F_FILE_OPEN_MODE_READ		0x1
#define F_FILE_OPEN_MODE_WRITE		0x2
#define F_FILE_OPEN_MODE_NEW		0x4
#define F_FILE_OPEN_MODE_CREADER    0x8

#define F_FILE_WRITE_MODE_RESTORE	0x0
#define F_FILE_WRITE_MODE_APPEND	0x1

#define F_TYPE_FILE			0
#define F_TYPE_DIR			1

#define F_FILE_EXIST		0
#define F_FILE_NOT_EXIST	1

@interface EUExFileMgr : EUExBase {
	NSMutableDictionary *fobjDict;
	FileExplorer *fExplorer;
}
-(void)uexOnFileMgrExplorerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData;
@end
