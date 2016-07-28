//
//  File.m
//  WebKitCorePlam
//
//  Created by AppCan on 11-9-14.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "File.h"
#include <sys/stat.h>
#include <time.h>

@implementation File
//创建目录
+(BOOL) createDir:(NSString *)dirName{
 	NSFileManager *fmanager = [NSFileManager defaultManager];	
	BOOL result =  [fmanager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil];
	return result;
}
//创建文件
+(BOOL)createFile:(NSString *)fileName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	BOOL result =[fmanager createFileAtPath:fileName contents:nil attributes:nil];
	return result;
}
//删除文件或文件夹
+(BOOL)removeDir:(NSString *)dirName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	BOOL result = [fmanager removeItemAtPath:dirName error:nil];  
	return result;
}
//打开一个文件
+(BOOL)openFile:(NSString *)fileName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	BOOL result = [fmanager fileExistsAtPath:fileName];
	return result;
} 
//重命名一个文件
+(BOOL)renameFileWithOldName:(NSString *)oldName newName:(NSString *)newName{
 
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSError *error;
	[fmanager moveItemAtPath:oldName toPath:newName error:&error];
	return YES;
}
//判断文件是否存在
+(BOOL)fileIsExist:(NSString *)fileName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	BOOL result = [fmanager fileExistsAtPath:fileName];
	return result;
}
//删除文件
+(BOOL)removeFile:(NSString *)fileName{
	//12.29---xll 
	BOOL result =NO;
	NSFileManager *fmanager = [NSFileManager defaultManager];	
	if ([fmanager fileExistsAtPath:fileName]) {
		result = [fmanager removeItemAtPath:fileName error:nil];
  }
	return result;
}
//得到documents的路径	
+(NSString *)getDocumentsPath:(NSString *)fileName{
	//转换成utf8格式
	NSData *fileData = [fileName dataUsingEncoding:NSUTF8StringEncoding];
	NSString *fileUtf8Name = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
	//获取documents路径
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *docPath = [documentsDirectory stringByAppendingPathComponent:fileUtf8Name];

	return docPath;
}
//获取文件长度
+(long long)getFileLength:(NSString *)fileName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSDictionary *dic = [fmanager attributesOfItemAtPath:fileName error:nil];	
	NSNumber *fileSize = [dic objectForKey:NSFileSize];
	
	
	return [fileSize longLongValue];
}
//遍历目录，每次返回一个子目录或文件名
+(NSString *)readDir:(NSString *)dirName{
	NSString *subFileName = nil;
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSArray *fileList = [fmanager subpathsOfDirectoryAtPath:dirName error:nil];
	static int index=0;
	if (index<[fileList count]) {
		subFileName = [fileList objectAtIndex:index];
		index++;
		return subFileName;
	}
	index=0;
	return subFileName;
}
//文件创建时间
+(NSDate *)fileCreateTime:(NSString *)fileName{
	NSDate *date;
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSDictionary *attDic = [fmanager attributesOfItemAtPath:fileName error:nil];
	if (attDic) {
		date = [attDic objectForKey:NSFileCreationDate];
	}else {
		date = [NSDate date];
	}
    
	return date;
}
//文件访问时间
+(int)fileAccessTime:(NSString *)fileName{
	struct stat st;   
   const char *name = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
	if (stat(name, &st) == 0) {
		time_t tt=st.st_atime;
		return (int)tt;
	}
	return -1;
}
//文件修改时间
+(NSDate *)fileModifyTime:(NSString *)fileName{
	NSDate *date;
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSDictionary *attDic = [fmanager attributesOfItemAtPath:fileName error:nil];
	if (attDic) {
		date = [attDic objectForKey:NSFileModificationDate];
	}else {
		date = [NSDate date];
	}
	return date;
}
//文件是否是一个目录
+(int)fileisDirectoy:(NSString *)fileName{
 	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSDictionary *fileInfo = [fmanager attributesOfItemAtPath:fileName error:nil];
	if (fileInfo) {
		NSString *ftype=[fileInfo  objectForKey:NSFileType];
		if ([ftype isEqual:NSFileTypeDirectory]){
			return 1;//is dir
		}else {
			return 0;//not dir
		}
	}
	return -1;//fail
}
//当前所在的目录
+(NSString *)currentDir:(NSString *)fileName{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSString *currentPath = [fmanager currentDirectoryPath];
	return currentPath;
}
@end
