//
//  FileListViewController.h
//  ABMutilChoose
//
//  Created by AppCan on 12-5-31.
//  Copyright 2012 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExFileMgr.h"

@interface FileListViewController: UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
	UITableView * table;
	NSArray *fileArray;
	NSMutableArray *pathArray;
	NSMutableArray *selectFiles;
	NSMutableArray *filesType;
	NSString *indexpath;
	UIToolbar* toolBar;
	NSInteger isEditableOrNot;
	Boolean root;

}
@property(nonatomic,retain) UITableView * table;
@property(nonatomic,retain)	NSArray *fileArray;
@property(nonatomic,retain)	NSMutableArray *pathArray;
@property(nonatomic,copy)	NSString *rootPath;
@property(nonatomic,copy)	NSString *indexpath;
@property(nonatomic,retain)	NSMutableArray *selectFiles;
@property(nonatomic,retain)	NSMutableArray *filesType;
@property(nonatomic,retain)	NSMutableDictionary *selectAllPaths;
@property(nonatomic,retain) UIToolbar* toolBar;
@property (nonatomic,weak)EUExFileMgr *euexObj;
@property (nonatomic,strong)void (^cb)(NSArray<NSString *> *selectedPaths);

- (instancetype)initWithRootPath:(NSString *)path completion:(void (^)(NSArray<NSString *> *selectedPaths))completion;



@end
