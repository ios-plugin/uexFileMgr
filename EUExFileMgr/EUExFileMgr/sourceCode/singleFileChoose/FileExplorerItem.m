//
//  FileExplorerItem.m
//  AppCan
//
//  Created by AppCan on 11-12-29.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "FileExplorerItem.h"
#import "File.h"

@implementation FileExplorerItem
@synthesize itemType,fileIcon,fileCreateTime,fileSize,fileName,fileType,subItems;
-(void)setFileTypeWithName:(NSString *)filename{
    NSString *smallName = [filename lowercaseString];
	if ([smallName hasSuffix:@"jpg"]||[smallName hasSuffix:@"jpeg"]||[smallName hasSuffix:@"png"]||[smallName hasSuffix:@"gif"]) {
		self.fileType = FILE_TYPE_IMAGE;
        self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_photo");
	}else if ([smallName hasSuffix:@"mov"]||[smallName hasSuffix:@"mp4"]||[smallName hasSuffix:@"avi"]||[smallName hasSuffix:@"3gp"]) {
		self.fileType = FILE_TYPE_VIDEO;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_video");
	}else if ([smallName hasSuffix:@"mp3"]) {
		self.fileType = FILE_TYPE_MUSIC;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_music");
	}else if ([smallName hasSuffix:@"zip"]) {
		self.fileType = FILE_TYPE_ZIP;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_zip");
	}else if ([smallName hasSuffix:@"txt"]||[smallName hasSuffix:@"rtf"]){
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_txt");
	}else if ([smallName hasSuffix:@"pdf"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_pdf");
	}else if ([smallName hasSuffix:@"doc"]||[smallName hasSuffix:@"docx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_doc");
	}else if ([smallName hasSuffix:@"ppt"]||[smallName hasSuffix:@"pptx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_ppt");
	}else if ([smallName hasSuffix:@"xls"]||[smallName hasSuffix:@"xlsx"]) {
		self.fileType = FILE_TYPE_DOCUMENT;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_excel");
	}else {
		self.fileType = FILE_TYPE_UNKNOW;
		self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_unknown");
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
                self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_folder");
            }else {
                self.fileIcon = UEX_FILEMGR_IMAGE_NAMED(@"plugin_file_emptyfolder");
            }
            
        }else {
            self.itemType = 0;//file
            [self setFileTypeWithName:fileName];
        }
        NSDate *filedate = [File fileCreateTime:inPath];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [df stringFromDate:filedate];
  
        self.fileCreateTime = dateStr;
        self.fileSize = @([File getFileLength:inPath]);
        
        return self;
    }else{
        return nil;
    }
}
 
-(void)dealloc{

}
@end
