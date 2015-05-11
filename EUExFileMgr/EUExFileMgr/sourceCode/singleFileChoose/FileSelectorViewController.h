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
- (void)fileSelectCancled:(id)filePicker;

@end

@interface FileSelectorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
 {
//	UITableViewController *tableController;
	NSMutableString *currentPath;
	NSMutableArray *fileItemArray;
	id< FileSelectorDelegate > delegate;
 
	 UIView *headView;
	 UILabel *headLabel;
	 UITableView *fTableView;
 
}
 
@property (nonatomic, retain) UITableView *fTableView;
@property (nonatomic, retain) UIView *headView;
@property (nonatomic, retain) UILabel *headLabel;
@property (nonatomic, retain) NSMutableString *currentPath;
@property (nonatomic, retain) NSMutableArray *fileItemArray;
@property (nonatomic,assign) id< FileSelectorDelegate > delegate;
-(id)initWithRootPath:(NSString *)inPath;
@end
