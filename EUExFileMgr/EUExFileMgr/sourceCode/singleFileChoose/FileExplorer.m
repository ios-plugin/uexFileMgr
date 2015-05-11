//
//  FileExplorer.m
//  WebKitCorePlam
//
//  Created by AppCan on 11-9-20.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "FileExplorer.h"
#import "EUExFileMgr.h"
//#import "EBrowserView.h"
//#import "EBrowserController.h"
//#import "BUtility.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"

@implementation FileExplorer

NSString *g_filePath = nil;

-(void)openWithEuex:(EUExFileMgr *)euexObj_ rootPath:(NSString *)inPath{
	euexObj = euexObj_;
	FileSelectorViewController *fileController = [[FileSelectorViewController alloc] initWithRootPath:inPath];
	fileController.delegate = self;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fileController];
    [nav shouldAutorotateToInterfaceOrientation:YES];
	[nav setModalPresentationStyle:UIModalPresentationCurrentContext];
    [EUtility brwView:euexObj.meBrwView presentModalViewController:nav animated:YES];
     
	[fileController release];
	[nav release];
}
- (void)fileSelectEnded:(NSString *)filepath{	
	if (g_filePath) {
		[g_filePath release];
		g_filePath = nil;
	}
	g_filePath = filepath;
	[g_filePath retain];
 	[euexObj uexOnFileMgrExplorerWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:g_filePath];
}

-(void)fileSelectCancled:(id)filePicker{
    [(UIViewController*)filePicker  dismissModalViewControllerAnimated:YES];
 }
-(void)dealloc{
	[super dealloc];
}
@end
