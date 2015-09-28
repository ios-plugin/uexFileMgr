//
//  FileExplorerItem.m
//  AppCan
//
//  Created by AppCan on 11-12-29.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "FileExplorerItem.h"
#import "File.h"
#import "EUtility.h"
@implementation FileExplorerItem
@synthesize itemType,fileIcon,fileCreateTime,fileSize,fileName,fileType,subItems;
-(void)setFileTypeWithName:(NSString *)filename{
    NSString *smallName = [filename lowercaseString];
	if ([smallName hasSuffix:@"jpg"]||[smallName hasSuffix:@"jpeg"]||[smallName hasSuffix:@"png"]||[smallName hasSuffix:@"gif"]) {
		self.fileType = FILE_TYPE_IMAGE;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_photo.png"];
	}else if ([smallName hasSuffix:@"mov"]||[smallName hasSuffix:@"mp4"]||[smallName hasSuffix:@"avi"]||[smallName hasSuffix:@"3gp"]) {
		self.fileType = FILE_TYPE_VIDEO;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_video.png"];
	}else if ([smallName hasSuffix:@"mp3"]) {
		self.fileType = FILE_TYPE_MUSIC;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_music.png"];
	}else if ([smallName hasSuffix:@"zip"]) {
		self.fileType = FILE_TYPE_ZIP;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_zip.png"];
	}else if ([smallName hasSuffix:@"txt"]||[smallName hasSuffix:@"rtf"]){
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_txt.png"];
	}else if ([smallName hasSuffix:@"pdf"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_pdf.png"];
	}else if ([smallName hasSuffix:@"doc"]||[smallName hasSuffix:@"docx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_doc.png"];
	}else if ([smallName hasSuffix:@"ppt"]||[smallName hasSuffix:@"pptx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_ppt.png"];
	}else if ([smallName hasSuffix:@"xls"]||[smallName hasSuffix:@"xlsx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_excel.png"];
	}else {
		self.fileType = FILE_TYPE_UNKNOW;
		self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_unknown.png"];
	}



}
-(id)initFileObjectWithPath:(NSString *)inPath{
    if (self = [super init]) {
        
//        if (![File fileIsExist:inPath]) {
//            return nil;
//        }
        self.fileName = [inPath lastPathComponent];
        if ([File fileisDirectoy:inPath]==1) {
            self.itemType = [NSNumber numberWithInt:1];//dir
            self.fileType = FILE_TYPE_DIRECTORY;
            self.subItems = [[NSFileManager defaultManager] subpathsAtPath:inPath];
            if ([subItems count]>0) {
                self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_folder.png"];
            }else {
                self.fileIcon = [UIImage imageNamed:@"uexFileMgr/plugin_file_emptyfolder.png"];
            }
            
        }else {
            self.itemType = 0;//file
            [self setFileTypeWithName:fileName];
        }
        NSDate *filedate = [File fileCreateTime:inPath];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [df stringFromDate:filedate];
        [df release];
        self.fileCreateTime = dateStr;
        self.fileSize = [NSNumber numberWithInt:[File getFileLength:inPath]];
        
        return self;
    }else{
        return nil;
    }
}
 
-(void)dealloc{
	[super dealloc];
	[fileIcon release];
	[fileCreateTime release];
	[fileSize release];
	[fileName release];
}
@end
