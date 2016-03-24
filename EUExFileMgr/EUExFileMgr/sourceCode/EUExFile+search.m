//
//  EUExFile+search.m
//  EUExFileMgr
//
//  Created by Cerino on 15/9/10.
//  Copyright (c) 2015年 xll. All rights reserved.
//

#import "EUExFile+search.h"

@implementation EUExFile (search)


+(void)searchFilesByPath:(NSString *)realPath
                  option:(uexFileMgrSearchOption)option
                keywords:(NSArray*)keywords
                suffixes:(NSArray*)suffixes
              conpletion:(void (^)(BOOL isSuccess,NSArray * result))completion{
    
    BOOL recursively = NO;
    if(option & uexFileMgrSearchRecursively){
        recursively=YES;
    }
    BOOL isIncludingFolder = NO;
    if(option & uexFileMgrSearchIncludingFolder){
        isIncludingFolder=YES;
    }
    NSArray *result =[self getFileListByPath:realPath
                                  withPrefix:@""
                                 recursively:recursively
                             includingFolder:isIncludingFolder];
    if(!result){
        if(completion){
            completion(NO,nil);
        }
    }
    NSMutableArray * filterResult = [NSMutableArray array];
    BOOL exactly=NO;
    if(option & uexFileMgrSearchExactly){
        exactly=YES;
    }
    
    for(NSString * aFile in result){
        if([self file:aFile hasSuffixes:suffixes]&&[self file:aFile fits:keywords exactly:exactly]){
            [filterResult addObject:aFile];
        }
    }
    if(completion){
        completion(YES,filterResult);
    }
}



+(NSArray *)getFileListByPath:(NSString *)path
                   withPrefix:(NSString *)prefix
                  recursively:(BOOL)recursively
              includingFolder:(BOOL)isIncludingFolder{
    NSFileManager *dm=[NSFileManager defaultManager];
    NSError * error =nil;
    NSMutableArray *result =[NSMutableArray array];
    NSArray *list = [dm contentsOfDirectoryAtPath:path error:&error];
    if(error||[list count]==0){
        return nil;
    }
    for(NSString *aFile in list){
        NSString* filePath =[path stringByAppendingPathComponent:aFile];
        BOOL isFolder;
        if([dm fileExistsAtPath:filePath isDirectory:&isFolder]){
            if(isFolder){//文件夹
                if(isIncludingFolder){
                    [result addObject:[NSString stringWithFormat:@"%@%@/",prefix,aFile]];
                }
                if(recursively){//递归搜索
                    NSArray *recurseArray =[self getFileListByPath:[NSString stringWithFormat:@"%@/%@",path,aFile]
                                                        withPrefix:[NSString stringWithFormat:@"%@%@/",prefix,aFile]
                                                       recursively:recursively
                                                   includingFolder:isIncludingFolder];
                    if(recurseArray){
                        for(NSString * file in recurseArray){
                            [result addObject:file];
                        }
                    }
                }
            }else{//不是文件夹
                [result addObject:[NSString stringWithFormat:@"%@%@",prefix,aFile]];
            }
        }
        
    }
    return result;
}

+(BOOL)file:(NSString *)fileName fits:(NSArray*)keywords exactly:(BOOL)exactly{
    if(!keywords ||[keywords count]==0){
        return YES;
    }
    if(exactly){
        fileName=[fileName lastPathComponent];
        fileName=[fileName stringByDeletingPathExtension];
    }
    
    for(NSString * aKeyword in keywords){
        if(exactly && [aKeyword isEqual:fileName]){
            return YES;
        }
        if(!exactly && [fileName rangeOfString:aKeyword].length >0){
            return YES;
        }
    }
    return NO;
}
+(BOOL)file:(NSString *)fileName hasSuffixes:(NSArray *)suffixes{
    if(!suffixes ||[suffixes count]==0){
        return YES;
    }
    for(NSString * aSuffix in suffixes){
        NSString * suffix =[NSString stringWithFormat:@".%@",aSuffix];
        if([fileName hasSuffix:suffix]){
            return YES;
        }
    }
    return NO;
    
}
@end
