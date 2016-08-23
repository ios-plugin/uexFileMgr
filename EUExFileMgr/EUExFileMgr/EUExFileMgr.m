/**
 *
 *	@file   	: EUExFileMgr.m  in EUExFileMgr
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 16/6/2.
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "EUExFileMgr.h"

#import "EUExFile.h"
#import "EUExFile+search.h"
#import "File.h"
#import "FileExplorer.h"
#import "FileListViewController.h"
#import <AppCanKit/ACEXTScope.h>

#define UEX_DO_IN_BACKGROUND(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

@interface EUExFileMgr()

@property (nonatomic,strong)NSMutableDictionary *fobjDict;//
@property (nonatomic,strong)FileExplorer *singlepicker;
@property (nonatomic,strong)UINavigationController *multipicker;


@end



#define UEX_FILE_NOT_FOUND_ERROR uexErrorMake(1,@"传入的file对象无效")

@implementation EUExFileMgr




#pragma mark - Life Cycle

- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    self = [super initWithWebViewEngine:engine];
    if (self) {
        _fobjDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clean{

}

#pragma mark - API









- (void )intCallbackWithFunc:(NSString *)functionKeyPath opid:(NSString *)inOpId isSuccess:(BOOL)isSuccess{
    if (isSuccess) {
        [self.webViewEngine callbackWithFunctionKeyPath:functionKeyPath arguments:ACArgsPack(@(inOpId.integerValue),@2,@0)];
    }else{
        [self.webViewEngine callbackWithFunctionKeyPath:functionKeyPath arguments:ACArgsPack(@(inOpId.integerValue),@2,@1)];
    }
}


//1.创建文件
- (UEX_BOOL)createFile:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateFile" opid:inOpId isSuccess:result];
    };

    if ([self.fobjDict objectForKey:inOpId]) {
        return UEX_FALSE;
    }
    EUExFile * uexFile=[[EUExFile alloc]init];
    inPath =[self absPath:inPath];
    result = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];

    
    return result ? UEX_TRUE : UEX_FALSE;
}






//2.创建目录
- (UEX_BOOL)createDir:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateDir" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile;
    if ([self.fobjDict objectForKey:inOpId]) {
        return UEX_FALSE;
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
    }
    
    return result ? UEX_TRUE : UEX_FALSE;
}




//3.打开文件
- (UEX_BOOL)openFile:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack( NSString *inOpId,NSString *inPath,NSString *inMode) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbOpenFile" opid:inOpId isSuccess:result];
        
    };
    EUExFile *uexFile = [self.fobjDict objectForKey:inOpId];
    if (uexFile) {
        inPath =[super absPath:inPath];
        BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
        if (isCreateFileSuccess) {
            result = YES;
        }
        return result ? UEX_TRUE : UEX_FALSE;
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
        [self.fobjDict setObject:uexFile forKey:inOpId];
    }
    return result ? UEX_TRUE : UEX_FALSE;
}



//4.打开目录
- (UEX_BOOL)openDir:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbOpenDir" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile = [self.fobjDict objectForKey:inOpId];
    if (uexFile) {
        return UEX_FALSE;
    }
    uexFile = [[EUExFile alloc] init];
    inPath = [super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR	path:inPath mode:0 euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
        [self.fobjDict setObject:uexFile forKey:inOpId];
    }
    return result ? UEX_TRUE : UEX_FALSE;
}



//5.通过path删除文件
- (UEX_BOOL)deleteFileByPath:(NSMutableArray *)inArguments {
    BOOL result = NO;
    ACArgsUnpack(NSString *inPath) = inArguments;
    inPath =[self absPath:inPath];
    if ([File fileIsExist:inPath] && [File removeFile:inPath]) {
        result = YES;
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbDeleteFileByPath" opid:@"0" isSuccess:result];
    return result ? UEX_TRUE : UEX_FALSE;
}
//6.删除一个文件通过ID
- (UEX_BOOL)deleteFileByID:(NSMutableArray *)inArguments {
    BOOL result = NO;
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];;
    NSString *truePath = object.appFilePath;
    if (truePath && [File fileIsExist:truePath] && [File removeFile:truePath]) {
        [self.fobjDict removeObjectForKey:inOpId];
        result = YES;
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbDeleteFileByID" opid:inOpId isSuccess:result];
    return result ? UEX_TRUE : UEX_FALSE;
}
//7.根据 path 判断文件类型
- (NSNumber *)getFileTypeByPath:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inPath) = inArguments;
    inPath = [self absPath:inPath];
    NSInteger result = [File fileisDirectoy:inPath];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileTypeByPath" arguments:ACArgsPack(@0,@2,@(result))];
    return @(result);
}


//8.根据 id判断文件类型
- (NSNumber *)getFileTypeByID:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSInteger result = -1;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        NSString *truePath = object.appFilePath;
        result = [File fileisDirectoy:truePath];
    }
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileTypeById" arguments:ACArgsPack(@0,@2,@(result))];
    return @(result);

}

//9.根据路径判断文件存在
- (UEX_BOOL)isFileExistByPath:(NSMutableArray *)inArguments {
    NSString *inOpId = nil;
    NSString *inPath = nil;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbIsFileExistByPath" opid:inOpId isSuccess:result];
    };
    if ([inArguments count] == 0) {
        return UEX_FALSE;
    }else if([inArguments count] == 1){
        inPath = stringArg(inArguments[0]);
    }else{
        inOpId = stringArg(inArguments[0]);
        inPath = stringArg(inArguments[1]);
    }
    if (!inOpId) {
        inOpId = @"0";
    }
    inPath = [self absPath:inPath];
    result = [File fileIsExist:inPath];
    return result ? UEX_TRUE : UEX_FALSE;
}

//10.根据ID判断文件存在
- (UEX_BOOL)isFileExistByID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *inOpId) = inArguments;
    BOOL result = NO;

    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        result = [File fileIsExist:object.appFilePath];
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbIsFileExistById" opid:inOpId isSuccess:result];
    return result ? UEX_TRUE : UEX_FALSE;
}

//11.文件浏览器

- (void)explorer:(NSMutableArray *)inArguments {
    if (self.singlepicker) {
        return;
    }
    
    ACArgsUnpack(NSString *inPath,ACJSFunctionRef *cb) = inArguments;
    __block UEX_ERROR err = kUexNoError;
    void (^callback)(NSString *result) = ^(NSString *result){
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbExplorer" arguments:ACArgsPack(@0,@0,result)];
        [cb executeWithArguments:ACArgsPack(err,result)];
    };
    if (!inPath) {
        callback(nil);
    }
    inPath = (inPath.length == 0) ? [File getDocumentsPath:@""] : [self absPath:inPath];
    
    self.singlepicker = [[FileExplorer alloc]initWithEUExObj:self rootPath:inPath];
    @weakify(self);
    [self.singlepicker presentControllerWithCompletion:^(NSString *selectedPath) {
        @strongify(self);
        if (!selectedPath) {
            err = uexErrorMake(1,@"用户取消选择");
        }
        callback(selectedPath);
        self.singlepicker = nil;
    }];
}
//multiExplorer
- (void)multiExplorer:(NSMutableArray*)inArguments{
    
    if (self.multipicker) {
        return;
    }
    
    ACArgsUnpack(NSString *inPath,ACJSFunctionRef *cb) = inArguments;
    inPath = [self absPath:inPath];
    @weakify(self);
    FileListViewController* filesView = [[FileListViewController alloc] initWithRootPath:inPath completion:^(NSArray<NSString *> *selectedPaths) {
        UEX_ERROR err = selectedPaths ? kUexNoError : uexErrorMake(1,@"用户取消选择");
        @strongify(self);
        [self.multipicker dismissViewControllerAnimated:YES completion:^{
            [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbMultiExplorer" arguments:ACArgsPack(@0,@1,selectedPaths)];
            [cb executeWithArguments:ACArgsPack(err,selectedPaths)];
            self.multipicker = nil;
        }];
        
    }];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filesView];
    self.multipicker = nav;
    [[self.webViewEngine viewController]presentViewController:nav animated:YES completion:nil];
}




//12.设置文件偏移
- (NSNumber *)seekFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPos) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        return @([object seek:inPos]);

    }
    return @(-1);
}

//13.文件偏移到开始
- (NSNumber *)seekBeginOfFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        return @([object seekBeginOfFile]);
    }
    return @(-1);
}

//14.文件偏移到最后
- (NSNumber *)seekEndOfFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        return  @([object seekEndOfFile]);
    }
    return @(-1);
}

//15.写文件
- (void)writeFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString * inOpId,NSNumber *opt,NSString * inData) = inArguments;
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    uexFileMgrFileWritingOption option = (uexFileMgrFileWritingOption)[opt integerValue];
    EUExFile * object = [self.fobjDict objectForKey:inOpId];
    if (!object) {
        [self intCallbackWithFunc:@"uexFileMgr.cbWriteFile" opid:inOpId isSuccess:NO];
        [cb executeWithArguments:ACArgsPack(UEX_FILE_NOT_FOUND_ERROR)];
        return;
    }
    UEX_DO_IN_BACKGROUND(^{
        BOOL ret = [object writeWithData:inData option:option];
        [self intCallbackWithFunc:@"uexFileMgr.cbWriteFile" opid:inOpId isSuccess:ret];
        UEX_ERROR err = kUexNoError;
        if (!ret) {
            err = uexErrorMake(1,@"文件写入失败");
        }
        [cb executeWithArguments:ACArgsPack(err)];
    });
}

//16.读文件
- (void)readFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString * inOpId,NSNumber *length,NSNumber *opt) = inArguments;
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    long long len = [length longLongValue];
    uexFileMgrFileReadingOption option = 0;
    if (opt) {
        option = (uexFileMgrFileReadingOption)[opt integerValue];
    }
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (!object) {
        UEX_ERROR err = UEX_FILE_NOT_FOUND_ERROR;
        [cb executeWithArguments:ACArgsPack(err,nil)];
        [self intCallbackWithFunc:@"uexFileMgr.cbReadFile" opid:inOpId isSuccess:NO];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *outStr = [object read:len option:option];
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadFile" arguments:ACArgsPack(@(inOpId.integerValue),@0,outStr)];
        [cb executeWithArguments:ACArgsPack(kUexNoError,outStr)];
    });
}


//文件夹大小
- (void)getFileSizeByPath:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    if(!info){
        return;
    }
    NSString *inOpId = stringArg(info[@"id"]);
    NSString *inPath = stringArg(info[@"path"]);
    NSString *unit = stringArg(info[@"unit"]).uppercaseString;
    
    UEX_DO_IN_BACKGROUND((^{

        
        CGFloat folderSize = [self folderSizeAtPath:[self absPath:inPath]];
        UEX_ERROR err = kUexNoError;
        
        NSInteger errorCode = (folderSize < 0) ? 1 : 0;
        NSMutableDictionary *result = [NSMutableDictionary dictionary];


        if([unit isEqual:@"KB"]){
            folderSize = folderSize / 1024;
        }
        if([unit isEqual:@"MB"]){
            folderSize = folderSize / 1024 / 1024;
        }
        if([unit isEqual:@"GB"]){
            folderSize = folderSize / 1024 / 1024 / 1024;
        }
        [result setValue:inOpId forKey:@"id"];
        [result setValue:@(folderSize) forKey:@"data"];
        [result setValue:unit forKey:@"unit"];
        [result setValue:@(errorCode) forKey:@"errorCode"];

        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileSizeByPath" arguments:ACArgsPack(result.ac_JSONFragment)];
        if (folderSize < 0) {
            err = uexErrorMake(1,@"文件或文件夹不存在");
            result = nil;
        }
        [cb executeWithArguments:ACArgsPack(err,result)];
    }));
}




- (CGFloat) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return (CGFloat)[[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return -1;
}
- (CGFloat) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]){
        return -1;
    }
    NSArray<NSString *> *subpaths = [manager subpathsAtPath:folderPath];
    __block CGFloat folderSize = 0;
    [subpaths enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        CGFloat fileSize = [self fileSizeAtPath:fileAbsolutePath];
        if (fileSize >= 0) {
            folderSize += fileSize;
        }
    }];
    return folderSize;
}
//17.文件大小
- (NSNumber *)getFileSize:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSNumber *fileSize = @(-1);
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        fileSize = @([[object getSize] longLongValue]);
    }
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileSize" arguments:ACArgsPack(@(inOpId.integerValue),@2,fileSize)];
    return fileSize;
}

- (NSString *)getFilePath:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSString *path = nil;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        path = [object getFilePath];
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFilePath" arguments:ACArgsPack(@(inOpId.integerValue),@0,path)];
    }else {
        UEX_FILE_NOT_FOUND_ERROR;
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFilePath" arguments:ACArgsPack(@(inOpId.integerValue),@2,@0)];
    }
    return path;
}



//19.关闭文件
- (UEX_BOOL)closeFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        [self.fobjDict removeObjectForKey:inOpId];
        return UEX_TRUE;
    }
    return UEX_FALSE;
}
//20. 返回阅读器的偏移值
- (NSNumber *)getReaderOffset:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSNumber *offset = @(-1);
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        offset = @([object getReaderOffset]);
        
    }
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetReaderOffset" arguments:ACArgsPack(@(inOpId.integerValue),@2,offset)];
    return offset;
    
}
//21.以阅读器形式读取指定数据
- (void)readPercent:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPercent,NSString *inLen,ACJSFunctionRef *cb) = inArguments;
    
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    UEX_DO_IN_BACKGROUND(^{
        NSString *data = nil;
        UEX_ERROR error = kUexNoError;
        if (!object) {
            error = UEX_FILE_NOT_FOUND_ERROR;
        }else{
            data = [object readPercent:inPercent Len:inLen];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadPercent" arguments:ACArgsPack(@(inOpId.integerValue),@0,data)];
        [cb executeWithArguments:ACArgsPack(error,data)];
        
    });
}



//22.以阅读器形式读取下一页
- (void)readNext:(NSMutableArray *)inArguments {
    ACArgsUnpack( NSString *inOpId,NSString *inLen,ACJSFunctionRef *cb) = inArguments;
    
    UEX_DO_IN_BACKGROUND(^{
        EUExFile *object = [self.fobjDict objectForKey:inOpId];
        NSString *data = nil;
        UEX_ERROR error = kUexNoError;
        if (!object) {
            error = UEX_FILE_NOT_FOUND_ERROR;
        }else{
             data = [object readNext:inLen];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadNext" arguments:ACArgsPack(@(inOpId.integerValue),@0,data)];
        [cb executeWithArguments:ACArgsPack(error,data)];
    });
}
//23.以阅读器形式读取上一页
- (void)readPre:(NSMutableArray *)inArguments {
    ACArgsUnpack( NSString *inOpId,NSString *inLen,ACJSFunctionRef *cb) = inArguments;
    
    
    
    UEX_DO_IN_BACKGROUND(^{
        EUExFile *object = [self.fobjDict objectForKey:inOpId];
        NSString *data = nil;
        UEX_ERROR error = kUexNoError;
        if (!object) {
            error = UEX_FILE_NOT_FOUND_ERROR;
        }else{
            data = [object readPre:inLen];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadPre" arguments:ACArgsPack(@(inOpId.integerValue),@0,data)];
        [cb executeWithArguments:ACArgsPack(error,data)];
    });
}
//24.拷贝文件
- (void)copyFile:(NSMutableArray *)inArguments{

    ACArgsUnpack(NSString *inOpId,NSString *inPath,NSString *toPath,ACJSFunctionRef *cb) = inArguments;


    NSString *fileName = [inPath lastPathComponent];
    toPath = [toPath stringByAppendingPathComponent:fileName];
    UEX_DO_IN_BACKGROUND(^{
        BOOL result = [[NSFileManager defaultManager] copyItemAtPath:[self absPath:inPath]
                                                              toPath:[self absPath:toPath]
                                                               error:nil];
        [self intCallbackWithFunc:@"uexFileMgr.cbCopyFile" opid:inOpId isSuccess:result];
        [cb executeWithArguments:ACArgsPack(@(result))];
    });
}



//获取文件的创建时间
- (NSString *)getFileCreateTime:(NSMutableArray *)inArguments{
    NSString *path = stringArg(inArguments.lastObject);
    NSString *inOpid = inArguments.count > 1 ? stringArg(inArguments[0]) : nil;
    NSString *dateStr = nil;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self absPath:path] error:nil];
    NSDate *creationDate =[fileAttributes objectForKey:NSFileCreationDate];
    if (creationDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateStr = [dateFormatter stringFromDate:creationDate];
    }
    
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileCreateTime" arguments:ACArgsPack(@(inOpid.integerValue),@0,dateStr)];
    return dateStr;
}



//真实路径
- (NSString *)getFileRealPath:(NSMutableArray *)inArguments {


    ACArgsUnpack(NSString *inPath,NSString *cbFuncName) = inArguments;
    if (!inPath || inPath.length == 0) {
        return nil;
    }
    

    NSString *outPath = [self absPath:inPath];
    if (cbFuncName && cbFuncName.length > 0) {
        [self.webViewEngine callbackWithFunctionKeyPath:[@"uexFileMgr." stringByAppendingString:cbFuncName] arguments:ACArgsPack(outPath)];
    }else{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileRealPath" arguments:ACArgsPack(outPath)];
    }
    return outPath;
}


- (NSArray *)getFileListByPath:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *path) = inArguments;
    __block NSMutableArray *result = nil;
    @onExit{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileListByPath" arguments:ACArgsPack(@0,@0,[result ac_JSONFragment])];
    };
    BOOL isDir = NO;
    NSFileManager *mgr = [NSFileManager defaultManager];
    path = [self absPath:path];
    if (![mgr fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        return result;
    }
    result = [NSMutableArray array];
    [[mgr contentsOfDirectoryAtPath:path error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:fileName forKey:@"fileName"];
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        [info setValue:filePath forKey:@"filePath"];
        BOOL isDir = NO;
        [mgr fileExistsAtPath:filePath isDirectory:&isDir];
        NSNumber *fileType = isDir ? @1 : @0;
        [info setValue:fileType forKey:@"fileType"];
        [result addObject:info];
    }];
    return  result;

}

/**
 *  重命名文件
 */
- (void)renameFile:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    __block UEX_ERROR err = kUexNoError;
    void (^callback)(NSInteger) = ^(NSInteger result){
        NSDictionary *resultDict = @{@"result":@(result)};
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbRenameFile" arguments:ACArgsPack(resultDict.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(err)];
    };
    NSString *oldPath = stringArg(info[@"oldFilePath"]);
    NSString *newPath = stringArg(info[@"newFilePath"]);
    
    if (!oldPath || !newPath) {
        callback(0);
        return;
    }
    
    UEX_DO_IN_BACKGROUND(^{
        NSError *error = nil;
        
        BOOL suc =[[NSFileManager defaultManager] moveItemAtPath:[self absPath:oldPath]
                                                          toPath:[self absPath:newPath]
                                                           error:&error];
        NSInteger result = 0;
        if (suc && !error) {
            result = 1;
            err = uexErrorMake(1,error.localizedDescription);
        }
        callback(result);
    });

}



- (void)search:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    NSString *path = stringArg(info[@"path"]);
    void (^callback)(BOOL isSuccess,NSArray *result) = ^(BOOL isSuccess,NSArray *result){
        NSMutableDictionary *dict =[NSMutableDictionary dictionary];
        UEX_ERROR err = kUexNoError;
        if(isSuccess){
            [dict setValue:@(YES) forKey:@"isSuccess"];
            [dict setValue:result forKey:@"result"];
        }else{
            err = uexErrorMake(1,@"search failed");
            [dict setValue:@(NO) forKey:@"isSuccess"];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbSearch" arguments:ACArgsPack([dict ac_JSONFragment])];
        [cb executeWithArguments:ACArgsPack(err,result)];
    };
    
    if (!path || path.length == 0) {
        callback(NO,nil);
        return;
    }
    
    
    
    uexFileMgrSearchOption opt =uexFileMgrSearchNone;
    NSNumber *optNum = numberArg(info[@"option"]);
    if (!optNum) {
        optNum = numberArg(info[@"flag"]);
    }
    if (optNum) {
        opt = optNum.integerValue;
    }

    NSArray *keywords = arrayArg(info[@"keywords"]);
    NSArray *suffixes = arrayArg(info[@"suffixes"]);
    UEX_DO_IN_BACKGROUND(^{
        [EUExFile searchFilesByPath:[self absPath:[info objectForKey:@"path"]]
                             option:opt
                           keywords:keywords
                           suffixes:suffixes
                         completion:callback];
    });
    



}



//1.使用密钥创建本地文件
- (UEX_BOOL)createSecure:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPath,NSString *inKey) = inArguments;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateSecure" opid:inOpId isSuccess:result];
    };
    

    EUExFile *uexFile;
    if ([self.fobjDict objectForKey:inOpId]) {
        return UEX_FALSE;
    }
    uexFile=[[EUExFile alloc]init];
    inPath =[self absPath:inPath];
    
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isCreateFileSuccess) {
        return UEX_FALSE;
    }
    //保存key
    if (inKey && inKey.length > 0) {
        [uexFile setKeyString:inKey];
    }
    [self.fobjDict setObject:uexFile forKey:inOpId];
    result = YES;
    return UEX_TRUE;
}

//2.使用密钥打开本地文件
- (UEX_BOOL)openSecure:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPath,NSString *inMode,NSString *inKey) = inArguments;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbOpenSecure" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile = [self.fobjDict objectForKey:inOpId];
    if (uexFile) {
        return UEX_FALSE;
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[self absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];

    if (!isCreateFileSuccess) {
        return UEX_FALSE;
    }
    //保存key
    if (inKey && inKey.length > 0) {
        [uexFile setKeyString:inKey];
    }
    [self.fobjDict setObject:uexFile forKey:inOpId];
    result = YES;
    return UEX_TRUE;
}

#pragma mark - 4.0 API

- (NSString *)create:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *path = [self absPath:stringArg(info[@"path"])];
    NSString *opid = stringArg(info[@"id"]) ?: newUUID();
    if (self.fobjDict[opid] || !path) {
        return nil;
    }
    
    EUExFile *uexFile=[[EUExFile alloc] init];
    BOOL isSuccess = [uexFile initWithFileType:F_TYPE_FILE path:path mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isSuccess) {
        return nil;
    }
    
    [self.fobjDict setValue:uexFile forKey:opid];
    
    return opid;
}

- (UEX_BOOL)mkdir:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *path = [self absPath:stringArg(info[@"path"])];
    EUExFile *uexFile = [[EUExFile alloc] init];
    BOOL isSuccess = [uexFile initWithFileType:F_TYPE_DIR path:path mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    return isSuccess ? UEX_TRUE : UEX_FALSE;
}

- (NSString *)open:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *path = [self absPath:stringArg(info[@"path"])];
    NSNumber *modeNum = numberArg(info[@"mode"]);
    NSString *opid = stringArg(info[@"id"]) ?: newUUID();
    if (!path || !modeNum) {
        ACLogDebug(@"file open error - invalid parameters with path:%@ mode:%@",path,modeNum);
        return nil;
    }

    EUExFile *uexFile = [self.fobjDict objectForKey:opid];
    if (uexFile) {
        if ([uexFile initWithFileType:F_TYPE_FILE path:path mode:[modeNum intValue] euexObj:self]) {
            return opid;
        }else{
            return nil;
        }
    }
    uexFile = [[EUExFile alloc] init];
    BOOL isSuccess = [uexFile initWithFileType:F_TYPE_FILE path:path mode:[modeNum intValue] euexObj:self];
    if (!isSuccess) {
        return nil;
    }
    [self.fobjDict setValue:uexFile forKey:opid];
    return opid;
}

- (void)copy:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cbFunc) = inArguments;
    NSString *src = stringArg(info[@"src"]);
    NSString *target = stringArg(info[@"target"]);
    __block UEX_ERROR err = kUexNoError;
    void (^callback)() = ^{
        [cbFunc executeWithArguments:ACArgsPack(err)];
    };
    if (!src || !target) {
        err = uexErrorMake(1,@"copy parameters error");
        callback();
        return;
    }
    UEX_DO_IN_BACKGROUND(^{
        
        @onExit{
            callback(err);
        };
        NSError *error = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *srcPath = [self absPath:src];

        if (![fm fileExistsAtPath:srcPath]) {
            err = uexErrorMake(1,@"copy error: source path invalid");
            return;
        }
        NSString *desFolderPath = [self absPath:target];
        BOOL isFolder = NO;
        if (![fm fileExistsAtPath:desFolderPath isDirectory:&isFolder] || !isFolder) {
            err = uexErrorMake(1,@"copy error: target folder not exist");
            return;
        }
        if (![[NSFileManager defaultManager]copyItemAtPath:srcPath toPath:[desFolderPath stringByAppendingPathComponent:srcPath.lastPathComponent] error:&error] || error) {
            err = uexErrorMake(1,@"copy error",@{@"info":error.localizedDescription});
            return;
        }
    });
}

- (NSString *)createWithPassword:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *opid = stringArg(info[@"id"]) ?: newUUID();
    NSString *path = stringArg(info[@"path"]);
    NSString *password = stringArg(info[@"password"]);
    if (!path || !password || password.length == 0 || self.fobjDict[opid]) {
        return nil;
    }
    NSString *truePath = [self absPath:path];
    EUExFile *file = [[EUExFile alloc]init];
    if (![file initWithFileType:F_TYPE_FILE path:truePath mode:F_FILE_OPEN_MODE_NEW euexObj:self]) {
        return nil;
    }
    [file setKeyString:password];
    [self.fobjDict setValue:file forKey:opid];
    return opid;
}


- (NSString *)openWithPassword:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *opid = stringArg(info[@"id"]) ?: newUUID();
    NSString *path = stringArg(info[@"path"]);
    NSString *password = stringArg(info[@"password"]);
    NSNumber *modeNum = numberArg(info[@"mode"]);
    if (!path || !password || !modeNum || self.fobjDict[opid]) {
        return nil;
    }
    NSString *truePath = [self absPath:path];
    EUExFile *file = [[EUExFile alloc]init];
    if (![file initWithFileType:F_TYPE_FILE path:truePath mode:[modeNum intValue] euexObj:self]) {
        return nil;
    }
    [file setKeyString:password];
    [self.fobjDict setValue:file forKey:opid];
    return opid;
}


#pragma mark - UUID

static inline NSString * newUUID(){
    return [NSUUID UUID].UUIDString;
}

@end
