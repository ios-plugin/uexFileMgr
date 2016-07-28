//
//  EUExFile.h
//  AppCan
//
//  Created by AppCan on 11-9-8.
//  Copyright 2011 AppCan. All rights reserved.
//

@class EBrowserController;
@class File;
#define F_PAGE_PRE			0
#define F_PAGE_NEXT			1
#define F_PAGE_PERCENT		2
@class EUExFileMgr;


typedef NS_OPTIONS(NSInteger, uexFileMgrFileWritingOption) {
    uexFileMgrFileWritingOptionSeekingToEnd = 1 << 0,
    uexFileMgrFileWritingOptionBase64Decoding = 1 << 1
    
};

typedef NS_OPTIONS(NSInteger, uexFileMgrFileReadingOption) {
    uexFileMgrFileReadingOptionBase64Encoding = 1 << 0
    
};

@interface EUExFile : NSObject {
	EUExFileMgr *euexObj;
	int fileType;
 	NSString *appFilePath;
	NSString *fileUrl;
	NSFileHandle *fileHandle;
	NSString *fileHasOpened;
    NSNumber *OS_offset;
	long long offset;
	NSNumber *currentLength;
}
@property(nonatomic, retain)NSNumber *currentLength;
@property(nonatomic,retain)NSString *appFilePath;
@property(nonatomic,retain)NSString *fileUrl;
@property(nonatomic,retain)NSFileHandle *fileHandle;
@property(nonatomic, retain)NSString *fileHasOpened;
@property(nonatomic, retain) NSNumber *OS_offset;
@property(nonatomic, retain)NSString* keyString;

-(BOOL)initWithFileType:(int)fileType_ path:(NSString *)inPath mode:(int)mode_ euexObj:(EUExFileMgr *)euexObj_;
-(BOOL)writeWithData:(NSString*)inData option:(uexFileMgrFileWritingOption)option;
//读文件
-(NSString*)read:(long long)len option:(uexFileMgrFileReadingOption)option;
//获得文件大小
-(NSString *)getSize;
-(NSString*)getFilePath;
-(void)seek:(NSString*)inPos;
-(void)seekBeginOfFile;
-(void)seekEndOfFile;
-(void)close;
//文件偏移
-(long long)getReaderOffset;
-(NSString*)readPre:(NSString*)inLen;
-(NSString*)readNext:(NSString*)inLen;
-(NSString*)readFilp:(int)inType len:(int)inLen;
-(NSString*)readPercent:(NSString*)inPercent Len:(NSString *)inLen;
@end
