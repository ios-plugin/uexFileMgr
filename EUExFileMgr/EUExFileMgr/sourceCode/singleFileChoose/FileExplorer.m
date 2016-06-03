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



@interface FileExplorer()
@property (nonatomic,weak)EUExFileMgr *euexObj;
@property (nonatomic,strong)NSString *rootPath;
@property (nonatomic,strong)UINavigationController *picker;
@property (nonatomic,strong)void (^cb)(NSString *);
@end

@implementation FileExplorer


- (instancetype)initWithEUExObj:(EUExFileMgr *)euexObj rootPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _euexObj = euexObj;
        _rootPath = path;
    }
    return self;
}

- (void)presentControllerWithCompletion:(void (^)(NSString *))completion{
    self.cb = completion;
    FileSelectorViewController *fileController = [[FileSelectorViewController alloc] initWithRootPath:self.rootPath];
    fileController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fileController];
    
    [nav setModalPresentationStyle:UIModalPresentationCurrentContext];
    self.picker = nav;
    [[self.euexObj.webViewEngine viewController]presentViewController:nav animated:YES completion:nil];
}


- (void)fileSelectEnded:(NSString *)filepath{
    
    [self.picker dismissViewControllerAnimated:YES completion:^{
        self.cb(filepath);
    }];

}

-(void)fileSelectCancled:(id)filePicker{
    [self.picker dismissViewControllerAnimated:YES completion:^{
        self.cb(nil);
    }];
 }

@end
