//
//  EUExFileMgr.m
//  AppCan
//
//  Created by AppCan on 11-9-8.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExFileMgr.h"
#import "EUtility.h"
#import "EUExFile.h"
#import "File.h"
#import "EUExBaseDefine.h"
#import "FileListViewController.h"
#import "JSON.h"
#import "EUExFile+search.h"



@implementation EUExFileMgr
//@synthesize fobjDict;
-(id)initWithBrwView:(EBrowserView *) eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
        fobjDict = [[NSMutableDictionary alloc]initWithCapacity:UEXFILEMGR_OBJECT_SIZE];
    }
    return self;
}

-(void)dealloc{
    if (fobjDict) {
        for (EUExFile *file in [fobjDict allValues]) {
            if (file) {
                [file release];
                file = nil;
            }
        }
        [fobjDict release];
        fobjDict = nil;
    }
    [fExplorer release];
    [super dealloc];
}

//1.使用密钥创建本地文件
-(void)createSecure:(NSMutableArray *)inArguments {
    PluginLog(@"[EUExFileMgr createSecure]");
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    NSString *inKey  = [inArguments objectAtIndex:2];
    
    EUExFile *uexFile;
    if ([fobjDict objectForKey:inOpId]) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        return;
    }else {
        uexFile=[[EUExFile alloc]init];
    }
    
    inPath =[self absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        //保存key
        if (inKey!=nil && [inKey isKindOfClass:[NSNull class]]==NO) {
            [uexFile setKeyString:inKey];
        }else {
            
        }
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbCreateSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    [uexFile release];
}

//2.使用密钥打开本地文件
-(void)openSecure:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    NSString *inMode = [inArguments objectAtIndex:2];
    NSString *inKey =  [inArguments objectAtIndex:3];
    
    EUExFile *uexFile = [fobjDict objectForKey:inOpId];
    if (uexFile) {
        [self jsSuccessWithName:@"uexFileMgr.cbOpenSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        return;
    }else {
        uexFile = [[EUExFile alloc] init];
    }
    
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
    
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbOpenSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        //保存key
        if (inKey!=nil && [inKey isKindOfClass:[NSNull class]]==NO) {
            [uexFile setKeyString:inKey];
        }else {
            
        }
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbOpenSecure" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    [uexFile release];
}

//1.创建文件
-(void)createFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    //12.29--xll
    EUExFile *uexFile;
    if ([fobjDict objectForKey:inOpId]) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        return;
    } else {
        uexFile=[[EUExFile alloc]init];
    }
    
    inPath =[self absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbCreateFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    //12.29---xll
    [uexFile release];
}
//2.创建目录
-(void)createDir:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    EUExFile *uexFile;
    if ([fobjDict objectForKey:inOpId]) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateDir" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        return;
    }else {
        uexFile = [[EUExFile alloc] init];
    }
    inPath =[super absPath:inPath];
    PluginLog(@"[EUExFileMgr createDir],inpath = %@",inPath);
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR path:inPath mode:F_FILE_OPEN_MODE_NEW euexObj:self];
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbCreateDir" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbCreateDir" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    [uexFile release];
}
//3.打开文件
-(void)openFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    NSString *inMode = [inArguments objectAtIndex:2];
    EUExFile *uexFile = [fobjDict objectForKey:inOpId];
    if (uexFile) {
        inPath =[super absPath:inPath];
        BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
        if (!isCreateFileSuccess) {
            [self jsSuccessWithName:@"uexFileMgr.cbOpenFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        }else {
            [self jsSuccessWithName:@"uexFileMgr.cbOpenFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
        }
        return;
    }
    else {
        uexFile = [[EUExFile alloc] init];
    }
    
    inPath =[super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_FILE path:inPath mode:[inMode intValue] euexObj:self];
    
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbOpenFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbOpenFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    [uexFile release];
}
//4.打开目录
-(void)openDir:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPath = [inArguments objectAtIndex:1];
    EUExFile *uexFile = [fobjDict objectForKey:inOpId];
    if (uexFile) {
        [self jsSuccessWithName:@"uexFileMgr.cbOpenFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        return;
    }else {
        uexFile = [[EUExFile alloc] init];
    }
    inPath = [super absPath:inPath];
    BOOL isCreateFileSuccess = [uexFile initWithFileType:F_TYPE_DIR	path:inPath mode:0 euexObj:self];
    
    if (!isCreateFileSuccess) {
        [self jsSuccessWithName:@"uexFileMgr.cbOpenDir" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }else {
        [fobjDict setObject:uexFile forKey:inOpId];
        [self jsSuccessWithName:@"uexFileMgr.cbOpenDir" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
    }
    [uexFile release];
}
//5.通过path删除文件
-(void)deleteFileByPath:(NSMutableArray *)inArguments {
    NSString *inPath = [inArguments objectAtIndex:0];
    inPath =[super absPath:inPath];
    
    //创建文件对象
    //如果文件存在，删除
    if ([File fileIsExist:inPath]) {
        if([File removeFile:inPath]){
            [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
        }else {
            [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        }
    }else {
        //失败
        [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
}
//6.删除一个文件通过ID
-(void)deleteFileByID:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object;
    if (fobjDict) {
        object = [fobjDict objectForKey:inOpId];
    }else {
        [self jsFailedWithOpId:0 errorCode:1090501 errorDes:UEX_ERROR_DESCRIBE_ARGS];
        return;
    }
    if (object!=nil) {
        NSString *truePath =object.appFilePath;
        if ([File fileIsExist:truePath]) {
            if ([File removeFile:truePath]) {
                [fobjDict removeObjectForKey:inOpId];
                [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByID" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
            }
            else {
                [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByID" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
            }
        }else
        {
            [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByID" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        }
    }else{
        [self jsSuccessWithName:@"uexFileMgr.cbDeleteFileByID" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
    
}
//7.根据 path 判断文件类型
-(void)getFileTypeByPath:(NSMutableArray *)inArguments {
    NSString *inPath = [inArguments objectAtIndex:0];
    inPath =[super absPath:inPath];
    if ([File fileIsExist:inPath]) {
        int isDir = [File fileisDirectoy:inPath];
        if (isDir==1) {
            [self jsSuccessWithName:@"uexFileMgr.cbGetFileTypeByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:F_TYPE_DIR];
        }else{
            [self jsSuccessWithName:@"uexFileMgr.cbGetFileTypeByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:F_TYPE_FILE];
        }
    }
}
//8.根据 id判断文件类型
-(void)getFileTypeByID:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *truePath = object.appFilePath;
        truePath = [truePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([File fileIsExist:truePath]) {
            int isDir = [File fileisDirectoy:truePath];
            if (isDir==1) {
                [self jsSuccessWithName:@"uexFileMgr.cbGetFileTypeById" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:F_TYPE_DIR];
            }else{
                [self jsSuccessWithName:@"uexFileMgr.cbGetFileTypeById" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:F_TYPE_FILE];
            }
        }else {
            [self jsFailedWithOpId:0 errorCode:1090702 errorDes:UEX_ERROR_DESCRIBE_FILE_EXIST];
        }
    }else {
        [self jsFailedWithOpId:0 errorCode:1090701 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
    
}

//9.根据路径判断文件存在
-(void)isFileExistByPath:(NSMutableArray *)inArguments {
    NSString *inOpId = nil;
    NSString *inPath = nil;
    if ([inArguments count]==2) {
        inOpId = [inArguments objectAtIndex:0];
        inPath = [inArguments objectAtIndex:1];
    }else {
        inPath = [inArguments objectAtIndex:0];
    }
    int retOpid = 0;
    if (inOpId) {
        retOpid = [inOpId intValue];
    }
    inPath = [super absPath:inPath];
    BOOL isExist = [File fileIsExist:inPath];
    if (isExist) {
        [self jsSuccessWithName:@"uexFileMgr.cbIsFileExistByPath" opId:retOpid dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CTRUE];
    }else{
        [self jsSuccessWithName:@"uexFileMgr.cbIsFileExistByPath" opId:retOpid dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFALSE];
    }
}

//10.根据ID判断文件存在
-(void)isFileExistByID:(NSMutableArray *)inArguments{
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *truePath = object.appFilePath;
        truePath = [truePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        BOOL isExist = [File fileIsExist:truePath];
        if (isExist) {
            [self jsSuccessWithName:@"uexFileMgr.cbIsFileExistById" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CTRUE];
        }else{
            [self jsSuccessWithName:@"uexFileMgr.cbIsFileExistById" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFALSE];
        }
    }else {
        [self jsFailedWithOpId:0 errorCode:1090901 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}
//11.文件浏览器

-(void)explorer:(NSMutableArray *)inArguments {
    
    NSString *inPath = [inArguments objectAtIndex:0];
    if (inPath == nil) {
        [super jsFailedWithOpId:0 errorCode:1091001 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
    if ([inPath length]==0) {
        inPath = [File getDocumentsPath:@""];
    }else {
        inPath =[super absPath:inPath];
        
        NSLog(@"++++++++++++++++++++++++++%@",inPath);
    }
    //open a file explorer
    fExplorer = [[FileExplorer alloc] init];
    [fExplorer openWithEuex:self rootPath:inPath];
    
}
//multiExplorer
-(void)multiExplorer:(NSMutableArray*)inArguments{
    NSString * inPath = nil;
    if ([inArguments count] > 0) {
        inPath = [self absPath:[inArguments objectAtIndex:0]];
    }
    
    FileListViewController* filesView = [[[FileListViewController alloc] init] autorelease];
    filesView.callBack = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filesView];
    [EUtility brwView:[super meBrwView] presentModalViewController:nav animated:(BOOL)YES];
    [nav release];

}
//12.设置文件偏移
-(void)seekFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPos = [inArguments objectAtIndex:1];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        [object seek:inPos];
    }else{
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091101 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}
//13.文件偏移到开始
-(void)seekBeginOfFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        [object seekBeginOfFile];
    }else {
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091201 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}
//14.文件偏移到最后
-(void)seekEndOfFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        [object seekEndOfFile];
    }else {
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091301 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
    
}

//15.写文件
-(void)writeFile:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 3) {
        
        return;
        
    }
    
    NSString * inOpId = [inArguments objectAtIndex:0];
    NSString * inMode = [inArguments objectAtIndex:1];
    NSString * inData = [inArguments objectAtIndex:2];
    
    EUExFile * object = [fobjDict objectForKey:inOpId];
    
    if (object != nil) {
        
        __block typeof(self) weakSelf = self;
        __block typeof(object) weakObject = object;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL ret = [weakObject writeWithData:inData mode:inMode];
            
            NSString * retStr = [NSString stringWithFormat:@"%d",ret];
            
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:inOpId,@"opId",retStr,@"ret",@"uexFileMgr.cbWriteFile",@"method", nil];
            
            [weakSelf performSelectorOnMainThread:@selector(uexCallBack:) withObject:userInfo waitUntilDone:NO];
            
        });
        
    } else {
        
        [self jsSuccessWithName:@"uexFileMgr.cbWriteFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091401 errorDes:UEX_ERROR_DESCRIBE_ARGS];
        
    }
    
}

- (void)uexCallBack:(id)userInfo {
    
    NSDictionary * dic = (NSDictionary *)userInfo;
    
    BOOL ret = [[dic objectForKey:@"ret"] boolValue];
    
    NSString * opId = [dic objectForKey:@"opId"];
    
    NSString * methodName = [dic objectForKey:@"method"];

    if (ret) {
        
        [self jsSuccessWithName:methodName opId:[opId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
        
    } else {
        
        [self jsSuccessWithName:methodName opId:[opId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        
    }
    
}

//16.读文件
-(void)readFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inLen = [inArguments objectAtIndex:1];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *outStr = [object read:inLen];
        PluginLog(@"[EUExFileMgr outStr=%@]",outStr);
        [self jsSuccessWithName:@"uexFileMgr.cbReadFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:outStr];
    }else {
        [self jsSuccessWithName:@"uexFileMgr.cbReadFile" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
}

//17.文件大小
-(void)getFileSize:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        long outSize = [object getSize];
        [self jsSuccessWithName:@"uexFileMgr.cbGetFileSize" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:outSize];
    }else {
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091601 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}

-(void)getFilePath:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *outPath = [object getFilePath];
        [self jsSuccessWithName:@"uexFileMgr.cbGetFilePath" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:outPath];
    }else {
        [self jsSuccessWithName:@"uexFileMgr.cbGetFilePath" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
        
    }
}

//19.关闭文件
-(void)closeFile:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    if ([fobjDict count]==0) {
        return;
    }
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        [fobjDict removeObjectForKey:inOpId];
    }else {
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091801 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}
//20. 返回阅读器的偏移值
-(void)getReaderOffset:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        long readerOffset = [object getReaderOffset];
        [self jsSuccessWithName:@"uexFileMgr.cbGetReaderOffset" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:readerOffset];
    }else {
        [self jsFailedWithOpId:[inOpId intValue] errorCode:1091901 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
    
    
}
//21.以阅读器形式读取指定数据
-(void)readPercent:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inPercent = [inArguments objectAtIndex:1];
    NSString *inLen = [inArguments objectAtIndex:2];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *res = [object readPercent:inPercent Len:inLen];
        [self jsSuccessWithName:@"uexFileMgr.cbReadPercent" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:res];
    }else {
        [self jsSuccessWithName:@"uexFileMgr.cbReadPercent" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
}
//22.以阅读器形式读取下一页
-(void)readNext:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inLen = [inArguments objectAtIndex:1];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *res = [object readNext:inLen];
        [self jsSuccessWithName:@"uexFileMgr.cbReadNext" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:res];
    }else {
        [self jsSuccessWithName:@"uexFileMgr.cbReadNext" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
}
//23.以阅读器形式读取上一页
-(void)readPre:(NSMutableArray *)inArguments {
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *inLen = [inArguments objectAtIndex:1];
    EUExFile *object = [fobjDict objectForKey:inOpId];
    if (object!=nil) {
        NSString *res = [object readPre:inLen];
        [self jsSuccessWithName:@"uexFileMgr.cbReadPre" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:res];
    }else {
        [self jsSuccessWithName:@"uexFileMgr.cbReadPre" opId:[inOpId intValue] dataType:UEX_CALLBACK_DATATYPE_TEXT intData:UEX_CFAILED];
    }
}


//获取文件的创建时间
-(void)getFileCreateTime:(NSMutableArray *)inArguments{
    NSString *inOpId = [inArguments objectAtIndex:0];
    NSString *path = [inArguments objectAtIndex:1];
     path =[super absPath:path];
    NSFileManager *fmanager;
    fmanager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fmanager attributesOfItemAtPath:path error:nil];

    NSString *time = [fileAttributes objectForKey:NSFileModificationDate];
    NSDate *localeDate =[fileAttributes objectForKey:NSFileCreationDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:localeDate];

    if (time) {
        [self jsSuccessWithName:@"uexFileMgr.cbGetFileCreateTime" opId:[inOpId intValue] dataType:0 strData:destDateString];
    }
}



//真实路径
-(void)getFileRealPath:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 1) {
        return;
    }
    
    NSString *inPath = [inArguments objectAtIndex:0];
    
    NSString *outPath = [self absPath:inPath];
    
    if ([inArguments count] > 1) {
        NSString * fun = [inArguments objectAtIndex:1];
        
        if (outPath) {
            NSString * jsStr = [NSString stringWithFormat:@"uexFileMgr.%@(\"%@\")",fun,outPath];
            
            [(UIWebView *)self.meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
        }
        
    } else {
        
        if (outPath) {
            [self jsSuccessWithName:@"uexFileMgr.cbGetFileRealPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:outPath];
        }
        
    }
    
    
}

//真实路径
-(void)getFileListByPath:(NSMutableArray *)inArguments {
    if ([inArguments isKindOfClass:[NSMutableArray class]] && [inArguments count]>0) {
        @autoreleasepool {
            NSString *inPath = [inArguments objectAtIndex:0];
            if ([inPath isKindOfClass:[NSString class]] && inPath.length>0) {
                NSString *path = [super absPath:inPath];
                //判断文件是否存在
                NSFileManager *fmanager = [NSFileManager defaultManager];
                if ([fmanager fileExistsAtPath:path]) {
                    //判断是否是文件夹
                    if ([File fileisDirectoy:path]) {
                        //NSArray *files = [fmanager subpathsAtPath:path];
                        NSError *error=nil;
                        NSArray *files = [fmanager contentsOfDirectoryAtPath:path error:&error];
                        if(error){
                            [self jsSuccessWithName:@"uexFileMgr.cbGetFileListByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@""];
                            return;
                        }
                        NSMutableArray *array_ = [NSMutableArray arrayWithCapacity:2];
                        if ([files isKindOfClass:[NSArray class]] && [files count]>0) {
                            for (NSString *fileName in files) {
                                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
                                [dict setObject:fileName forKey:@"fileName"];
                                fileName = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
                                [dict setObject:fileName forKey:@"filePath"];
                                if ([File fileisDirectoy:fileName]) {
                                    [dict setObject:@"1" forKey:@"fileType"];
                                }else{
                                    [dict setObject:@"0" forKey:@"fileType"];
                                }
                                [array_ addObject:dict];
                            }
                        }else{
                            
                        }
                        [self jsSuccessWithName:@"uexFileMgr.cbGetFileListByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:[array_ JSONFragment]];
                    }
                }else{
                    [self jsSuccessWithName:@"uexFileMgr.cbGetFileListByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@""];
                }
            }else{
                [self jsSuccessWithName:@"uexFileMgr.cbGetFileListByPath" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@""];
            }
        }
    }
}

-(void)uexOnFileMgrExplorerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData{
    inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self jsSuccessWithName:@"uexFileMgr.cbExplorer" opId:inOpId dataType:inDataType strData:inData];
}

/**
 *  重命名文件
 */
-(void)renameFile:(NSMutableArray *)inArguments{
    
    if([inArguments count]<1){
        [self cbRenameFile:0];
        return;
    }
    NSError *error=nil;
    NSData *jsonData= [inArguments[0] dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];

    if(error||![jsonObject objectForKey:@"oldFilePath"]||![jsonObject objectForKey:@"newFilePath"]){
        [self cbRenameFile:0];
        return;
    }
    NSFileManager *fmgr = [NSFileManager defaultManager];
    NSString *oldFilePath=[self absPath:[jsonObject objectForKey:@"oldFilePath"]];
    NSString *newFilePath=[self absPath:[jsonObject objectForKey:@"newFilePath"]];
    [fmgr moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
    if(error){
        [self cbRenameFile:0];
    }else{
        [self cbRenameFile:1];
    }
    
}

-(void)cbRenameFile:(NSInteger)type{
    NSDictionary *dict;
    if(type == 0){
        dict=@{@"result":@"0"};
    }else if(type == 1){
        dict=@{@"result":@"1"};
    }else return;

    NSString *callBackStr=[NSString stringWithFormat:@"if(uexFileMgr.cbRenameFile != null){uexFileMgr.cbRenameFile('%@');}",[dict JSONFragment]];
    [EUtility brwView:meBrwView evaluateScript:callBackStr];
}


-(void)search:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        [self cbSearch:NO result:nil];
        return;
    }
    id info =[inArguments[0] JSONValue];
    if(![info isKindOfClass:[NSDictionary class]]||![info objectForKey:@"path"]||![[info objectForKey:@"path"] isKindOfClass:[NSString class]]){
        [self cbSearch:NO result:nil];
        return;
    }
    uexFilrMgrSearchOption opt =uexFilrMgrSearchNone;
    if([info objectForKey:@"option"]){
        NSInteger num=[[info objectForKey:@"option"] integerValue];
        if(num >-1 && num <9){
            opt=(uexFilrMgrSearchOption)num;
        }
    }
    NSArray *keywords=nil;
    
    if([info objectForKey:@"keywords"] && [[info objectForKey:@"keywords"] isKindOfClass:[NSArray class]]){
        keywords=[info objectForKey:@"keywords"];
    }
    NSArray * suffixes=nil;
    if([info objectForKey:@"suffixes"] && [[info objectForKey:@"suffixes"] isKindOfClass:[NSArray class]]){
        suffixes=[info objectForKey:@"suffixes"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [EUExFile searchFilesByPath:[self absPath:[info objectForKey:@"path"]]
                             option:opt
                           keywords:keywords
                           suffixes:suffixes
                         conpletion:^(BOOL isSuccess, NSArray *result) {
                             [self cbSearch:isSuccess result:result];
                         }];
    });
    
    
    
}


-(void)cbSearch:(BOOL)isSuccess result:(NSArray *)result{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    
    if(isSuccess){
        [dict setValue:@(YES) forKey:@"isSuccess"];
        [dict setValue:result forKey:@"result"];
        
    }else{
        [dict setValue:@(NO) forKey:@"isSuccess"];
    }
    NSString *cbStr=[NSString stringWithFormat:@"if(uexFileMgr.cbSearch != null){uexFileMgr.cbSearch('%@');}",[dict JSONFragment]];
    [EUtility brwView:meBrwView evaluateScript:cbStr];

    
}

-(void)clean{
    if (meBrwView) {
        meBrwView = nil;
    }
    [fobjDict removeAllObjects];
}

@end
