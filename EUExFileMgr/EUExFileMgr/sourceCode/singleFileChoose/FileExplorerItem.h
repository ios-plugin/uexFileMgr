//
//  FileExplorerItem.h
//  AppCan
//
//  Created by AppCan on 11-12-29.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
enum file_explorer_file_type {
	FILE_TYPE_DIRECTORY=0,
	FILE_TYPE_IMAGE,
	FILE_TYPE_MUSIC,
	FILE_TYPE_VIDEO,
	FILE_TYPE_ZIP,
	FILE_TYPE_DOCUMENT,
	FILE_TYPE_UNKNOW
	
};

@interface FileExplorerItem : NSObject {
	NSNumber *itemType;//file or directory
	UIImage *fileIcon;  //image
	NSString *fileCreateTime;
	NSNumber *fileSize;
	NSString *fileName;
	NSInteger fileType;
	NSArray *subItems;
}
@property (nonatomic ,retain)NSNumber *itemType;
@property NSInteger fileType;
@property(nonatomic, retain)UIImage *fileIcon;
@property(nonatomic, retain)NSString *fileCreateTime;
@property(nonatomic, retain)NSNumber *fileSize;
@property(nonatomic, retain)NSString *fileName;
@property(nonatomic, retain)NSArray *subItems;
-(id)initFileObjectWithPath:(NSString *)inPath;
@end
