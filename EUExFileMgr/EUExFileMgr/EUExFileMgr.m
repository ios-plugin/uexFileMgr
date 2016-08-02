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


@implementation EUExFileMgr

#define UEX_ERROR NSNumber *


static UEX_ERROR kError;
static UEX_ERROR kNoError;

__attribute__((constructor)) static void initUexConstant(){
    kError = @(YES);
    kNoError = @(NO);
}



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
- (NSNumber *)createFile:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateFile" opid:inOpId isSuccess:result];
    };

    if ([self.fobjDict objectForKey:inOpId]) {
        return @(result);
    }
    EUExFile * uexFile=[[EUExFile alloc]init];
    inPath =[self absPath:inPath];
    result = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];

    
    return @(result);
}






//2.创建目录
- (NSNumber *)createDir:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateDir" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile;
    if ([self.fobjDict objectForKey:inOpId]) {
        return @(result);
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
    }
    
    return @(result);
}




//3.打开文件
- (NSNumber *)openFile:(NSMutableArray *)inArguments {
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
        return @(result);
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
        [self.fobjDict setObject:uexFile forKey:inOpId];
    }
    return @(result);
}



//4.打开目录
- (NSNumber *)openDir:(NSMutableArray *)inArguments {
    __block BOOL result = NO;
    ACArgsUnpack(NSString *inOpId,NSString *inPath) = inArguments;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbOpenDir" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile = [self.fobjDict objectForKey:inOpId];
    if (uexFile) {
        return @(result);
    }
    uexFile = [[EUExFile alloc] init];
    inPath = [super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR	path:inPath mode:0 euexObj:self];
    if (isCreateFileSuccess) {
        result = YES;
        [self.fobjDict setObject:uexFile forKey:inOpId];
    }
    return @(result);
}



//5.通过path删除文件
- (NSNumber *)deleteFileByPath:(NSMutableArray *)inArguments {
    BOOL result = NO;
    ACArgsUnpack(NSString *inPath) = inArguments;
    inPath =[self absPath:inPath];
    if ([File fileIsExist:inPath] && [File removeFile:inPath]) {
        result = YES;
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbDeleteFileByPath" opid:@"0" isSuccess:result];
    return @(result);
}
//6.删除一个文件通过ID
- (NSNumber *)deleteFileByID:(NSMutableArray *)inArguments {
    BOOL result = NO;
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];;
    NSString *truePath = object.appFilePath;
    if (truePath && [File fileIsExist:truePath] && [File removeFile:truePath]) {
        [self.fobjDict removeObjectForKey:inOpId];
        result = YES;
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbDeleteFileByID" opid:inOpId isSuccess:result];
    return @(result);
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
- (NSNumber *)isFileExistByPath:(NSMutableArray *)inArguments {
    NSString *inOpId = nil;
    NSString *inPath = nil;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbIsFileExistByPath" opid:inOpId isSuccess:result];
    };
    if ([inArguments count] == 0) {
        return @(result);
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
    return @(result);
}

//10.根据ID判断文件存在
- (NSNumber *)isFileExistByID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *inOpId) = inArguments;
    BOOL result = NO;

    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        result = [File fileIsExist:object.appFilePath];
    }
    [self intCallbackWithFunc:@"uexFileMgr.cbIsFileExistById" opid:inOpId isSuccess:result];
    return @(result);
}

//11.文件浏览器

- (void)explorer:(NSMutableArray *)inArguments {
    if (self.singlepicker) {
        return;
    }
    
    ACArgsUnpack(NSString *inPath,ACJSFunctionRef *cb) = inArguments;
    void (^callback)(NSString *result) = ^(NSString *result){
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbExplorer" arguments:ACArgsPack(@0,@0,result)];
        [cb executeWithArguments:ACArgsPack(result)];
    };
    if (!inPath) {
        callback(nil);
    }
    inPath = (inPath.length == 0) ? [File getDocumentsPath:@""] : [self absPath:inPath];
    
    self.singlepicker = [[FileExplorer alloc]initWithEUExObj:self rootPath:inPath];
    @weakify(self);
    [self.singlepicker presentControllerWithCompletion:^(NSString *selectedPath) {
        @strongify(self);
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
        @strongify(self);
        [self.multipicker dismissViewControllerAnimated:YES completion:^{
            [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbMultiExplorer" arguments:ACArgsPack(@0,@1,selectedPaths)];
            [cb executeWithArguments:ACArgsPack(selectedPaths)];
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
        [object seek:inPos];
        return @YES;
    }
    return @NO;
}

//13.文件偏移到开始
- (NSNumber *)seekBeginOfFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        [object seekBeginOfFile];
        return @YES;
    }
    return @NO;
}

//14.文件偏移到最后
- (NSNumber *)seekEndOfFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        [object seekEndOfFile];
        return @YES;
    }
    return @NO;
}

//15.写文件
- (void)writeFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString * inOpId,NSNumber *opt,NSString * inData) = inArguments;
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    uexFileMgrFileWritingOption option = (uexFileMgrFileWritingOption)[opt integerValue];
    EUExFile * object = [self.fobjDict objectForKey:inOpId];
    if (!object) {
        [self intCallbackWithFunc:@"uexFileMgr.cbWriteFile" opid:inOpId isSuccess:NO];
        [cb executeWithArguments:ACArgsPack(@(NO))];
        return;
    }
    UEX_DO_IN_BACKGROUND(^{
        BOOL ret = [object writeWithData:inData option:option];
        [self intCallbackWithFunc:@"uexFileMgr.cbWriteFile" opid:inOpId isSuccess:ret];
        [cb executeWithArguments:ACArgsPack(@(ret))];
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
        [cb executeWithArguments:ACArgsPack(kError,nil)];
        [self intCallbackWithFunc:@"uexFileMgr.cbReadFile" opid:inOpId isSuccess:NO];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *outStr = [object read:len option:option];
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadFile" arguments:ACArgsPack(@(inOpId.integerValue),@0,outStr)];
        [cb executeWithArguments:ACArgsPack(kNoError,outStr)];
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
        NSString *fileSize = @"0";
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        CGFloat folderSize = [self folderSizeAtPath:[self absPath:inPath]];
        NSInteger errorCode = folderSize > 0 ? 0 : 1 ;
        if([unit isEqual:@"KB"]){
            folderSize = folderSize / 1024;
        }
        if([unit isEqual:@"MB"]){
            folderSize = folderSize / 1024 / 1024;
        }
        if([unit isEqual:@"GB"]){
            folderSize = folderSize / 1024 / 1024 / 1024;
        }
        fileSize = [NSString stringWithFormat:@"%f",folderSize];
        [result setValue:@(errorCode) forKey:@"errorCode"];
        [result setValue:inOpId forKey:@"id"];
        [result setValue:fileSize forKey:@"data"];
        [result setValue:unit forKey:@"unit"];
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFileSizeByPath" arguments:ACArgsPack(result.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(result)];
    }));
}




- (CGFloat) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return (CGFloat)[[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (CGFloat) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]){
        return 0;
    }
    NSArray<NSString *> *subpaths = [manager subpathsAtPath:folderPath];
    __block CGFloat folderSize = 0;
    [subpaths enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }];
    return folderSize;
}
//17.文件大小
- (NSString *)getFileSize:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSString *fileSize = nil;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        fileSize = [object getSize];
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
        ACLogDebug(@"file for id:%@ NOT found!",inOpId);
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbGetFilePath" arguments:ACArgsPack(@(inOpId.integerValue),@2,@0)];
    }
    return path;
}



//19.关闭文件
- (NSNumber *)closeFile:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        [self.fobjDict removeObjectForKey:inOpId];
        return @YES;
    }
    return @NO;
}
//20. 返回阅读器的偏移值
- (NSString *)getReaderOffset:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId) = inArguments;
    NSString *offset = nil;
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    if (object) {
        offset = @([object getReaderOffset]).stringValue;
        
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
        UEX_ERROR error = kError;
        if (object) {
            data = [object readPercent:inPercent Len:inLen];
            error = kNoError;
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadPercent" arguments:ACArgsPack(@(inOpId.integerValue),@0,data)];
        [cb executeWithArguments:ACArgsPack(error,data)];
        
    });
}



//22.以阅读器形式读取下一页
- (void)readNext:(NSMutableArray *)inArguments {
    ACArgsUnpack( NSString *inOpId,NSString *inLen,ACJSFunctionRef *cb) = inArguments;
    
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    
    UEX_DO_IN_BACKGROUND(^{
        NSString *data = nil;
        UEX_ERROR error = kError;
        if (object) {
            data = [object readNext:inLen];
            error = kNoError;
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbReadNext" arguments:ACArgsPack(@(inOpId.integerValue),@0,data)];
        [cb executeWithArguments:ACArgsPack(error,data)];
    });
}
//23.以阅读器形式读取上一页
- (void)readPre:(NSMutableArray *)inArguments {
    ACArgsUnpack( NSString *inOpId,NSString *inLen,ACJSFunctionRef *cb) = inArguments;
    
    EUExFile *object = [self.fobjDict objectForKey:inOpId];
    
    UEX_DO_IN_BACKGROUND(^{
        NSString *data = nil;
        UEX_ERROR error = kError;
        if (object) {
            data = [object readPre:inLen];
            error = kNoError;
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
    void (^callback)(NSInteger) = ^(NSInteger result){
        NSDictionary *resultDict = @{@"result":@(result)};
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbRenameFile" arguments:ACArgsPack(resultDict.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(resultDict)];
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
        }
        callback(result);
    });

}



- (void)search:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    NSString *path = stringArg(info[@"path"]);
    void (^callback)(BOOL isSuccess,NSArray *result) = ^(BOOL isSuccess,NSArray *result){
        NSMutableDictionary *dict =[NSMutableDictionary dictionary];
        if(isSuccess){
            [dict setValue:@(YES) forKey:@"isSuccess"];
            [dict setValue:result forKey:@"result"];
        }else{
            [dict setValue:@(NO) forKey:@"isSuccess"];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFileMgr.cbSearch" arguments:ACArgsPack([dict ac_JSONFragment])];
        [cb executeWithArguments:ACArgsPack(dict)];
    };
    
    if (!path || path.length == 0) {
        callback(NO,nil);
        return;
    }
    
    
    
    uexFileMgrSearchOption opt =uexFileMgrSearchNone;
    NSNumber *optNum = numberArg(info[@"option"]);
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
- (NSNumber *)createSecure:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPath,NSString *inKey) = inArguments;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbCreateSecure" opid:inOpId isSuccess:result];
    };
    

    EUExFile *uexFile;
    if ([self.fobjDict objectForKey:inOpId]) {
        return @(result);
    }
    uexFile=[[EUExFile alloc]init];
    inPath =[self absPath:inPath];
    
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isCreateFileSuccess) {
        return @(result);
    }
    //保存key
    if (inKey && inKey.length > 0) {
        [uexFile setKeyString:inKey];
    }
    [self.fobjDict setObject:uexFile forKey:inOpId];
    result = YES;
    return @(result);
}

//2.使用密钥打开本地文件
- (NSNumber *)openSecure:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inOpId,NSString *inPath,NSString *inMode,NSString *inKey) = inArguments;
    __block BOOL result = NO;
    @onExit{
        [self intCallbackWithFunc:@"uexFileMgr.cbOpenSecure" opid:inOpId isSuccess:result];
    };
    EUExFile *uexFile = [self.fobjDict objectForKey:inOpId];
    if (uexFile) {
        return @(result);
    }
    uexFile = [[EUExFile alloc] init];
    inPath =[self absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];

    if (!isCreateFileSuccess) {
        return @(result);
    }
    //保存key
    if (inKey && inKey.length > 0) {
        [uexFile setKeyString:inKey];
    }
    [self.fobjDict setObject:uexFile forKey:inOpId];
    result = YES;
    return @(result);
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

- (NSNumber *)mkdir:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *inPath) = inArguments;
    NSString *path = [self absPath:inPath];
    EUExFile *uexFile = [[EUExFile alloc] init];
    BOOL isSuccess = [uexFile initWithFileType:F_TYPE_DIR path:path mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    return @(isSuccess);
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
    void (^callback)(UEX_ERROR error) = ^(UEX_ERROR error){
        [cbFunc executeWithArguments:ACArgsPack(error)];
    };
    if (!src || !target) {
        ACLogDebug(@"copy parameters error - src: %@ target: %@",src,target);
        callback(kError);
        return;
    }
    UEX_DO_IN_BACKGROUND(^{
        __block UEX_ERROR err = kError;
        @onExit{
            callback(err);
        };
        NSError *error = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *srcPath = [self absPath:src];

        if (![fm fileExistsAtPath:srcPath]) {
            ACLogDebug(@"copy error: source path invalid");
            return;
        }
        NSString *desFolderPath = [self absPath:target];
        BOOL isFolder = NO;
        if (![fm fileExistsAtPath:desFolderPath isDirectory:&isFolder] || !isFolder) {
            ACLogDebug(@"copy error: target folder not exist");
            return;
        }
        if (![[NSFileManager defaultManager]copyItemAtPath:srcPath toPath:[desFolderPath stringByAppendingPathComponent:srcPath.lastPathComponent] error:&error] || error) {
            ACLogDebug(@"copy error: %@",error.localizedDescription);
            return;
        }
        err = kNoError;
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
