//
//  FileSelectorViewController.h
//  AppCan
//
//  Created by AppCan on 11-2-25.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileSelectorDelegate <NSObject>

- (void)fileSelectEnded:(NSString *)filepath; 
- (void)fileSelectCancled:(UIViewController *)filePicker;

@end

@interface FileSelectorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *fTableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UILabel *headLabel;
@property (nonatomic, strong) NSMutableString *currentPath;
@property (nonatomic, strong) NSMutableArray *fileItemArray;
@property (nonatomic, strong) NSString *chuanRuPath;

@property (nonatomic,weak) id<FileSelectorDelegate> delegate;
-(id)initWithRootPath:(NSString *)inPath;
@end
