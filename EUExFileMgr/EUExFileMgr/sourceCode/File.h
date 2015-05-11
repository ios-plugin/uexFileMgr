//
//  File.h
//  WebKitCorePlam
//
//  Created by AppCan on 11-9-14.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface File : NSObject {

}
+(NSString *)getDocumentsPath:(NSString *)fileName;
+(BOOL) createDir:(NSString *)dirName;
+(BOOL)createFile:(NSString *)fileName;
+(BOOL)removeDir:(NSString *)dirName;
+(BOOL)openFile:(NSString *)fileName;
+(BOOL)renameFileWithOldName:(NSString *)oldName newName:(NSString *)newName;
+(BOOL)fileIsExist:(NSString *)fileName;
+(BOOL)removeFile:(NSString *)fileName;
+(NSString *)readDir:(NSString *)dirName;
+(NSDate *)fileCreateTime:(NSString *)fileName;
+(int)fileAccessTime:(NSString *)fileName;
+(long)getFileLength:(NSString *)fileName;
+(NSDate *)fileModifyTime:(NSString *)fileName;
+(int)fileisDirectoy:(NSString *)fileName;
+(NSString *)currentDir:(NSString *)fileName;
@end
