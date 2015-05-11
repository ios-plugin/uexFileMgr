//
//  EUExFile.m
//  AppCan
//
//  Created by AppCan on 11-9-8.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExFile.h"
#import "EUExFileMgr.h"
//#import "BUtility.h"
#import "File.h"
#import "EUtility.h"
@implementation EUExFile
@synthesize fileUrl;
@synthesize fileHandle;
@synthesize appFilePath;
@synthesize fileHasOpened;
@synthesize OS_offset,currentLength;
@synthesize keyString;

-(BOOL)initWithFileType:(int)fileType_ path:(NSString *)inPath mode:(int)mode_ euexObj:(EUExFileMgr *)euexObj_{
	fileType = fileType_;
	euexObj = euexObj_;
	self.appFilePath = inPath;
	NSRange range = [inPath rangeOfString:@"Documents"];
	if (range.length>0) {
		self.fileUrl = [inPath substringFromIndex:range.location+9];
	}else {
		NSRange rangeRes = [inPath rangeOfString:@".app"];
        if (rangeRes.length>0) {
            self.fileUrl = [inPath substringFromIndex:rangeRes.location+4];
        }
		if (mode_==F_FILE_OPEN_MODE_WRITE) {
			return NO;
		}
	}
	if (fileType_==F_TYPE_DIR) {
		if (![File fileIsExist:inPath]) {
			if ([File createDir:inPath]) {
				return YES;
			}else {
				return NO;
			}
		} else {
			return YES;
		}
	}
	switch (mode_) {
		case F_FILE_OPEN_MODE_NEW:
		case F_FILE_OPEN_MODE_WRITE:
		case F_FILE_OPEN_MODE_WRITE | F_FILE_OPEN_MODE_NEW:
		case F_FILE_OPEN_MODE_NEW   | F_FILE_OPEN_MODE_READ:
		case F_FILE_OPEN_MODE_READ  | F_FILE_OPEN_MODE_WRITE:	{
			if ([File fileIsExist:inPath]) {
				return YES;
			} 
            NSString *docPath = [inPath substringWithRange:NSMakeRange(0, [inPath length]-([[inPath lastPathComponent] length]))];
			if (![File fileIsExist:docPath]) {
				[File createDir:docPath];
			}
			if ([File createFile:inPath]) {
				return YES;
			}else {
				return NO;
			}

		}
			break;
		case F_FILE_OPEN_MODE_CREADER:
		case F_FILE_OPEN_MODE_READ:
		{
			if ([File fileIsExist:inPath]) {
				return YES;
			}else {
				return NO;
			}
		}
			break;
		default:
			break;
	}
	return NO;
} 

//写文件
-(void)writeWithData:(NSString*)inData mode:(NSString*)inMode{
	if (appFilePath==nil) {
		return;
	}
	NSData *writer = [inData dataUsingEncoding:NSUTF8StringEncoding];
//	BOOL mode = NO;
	inMode = [inMode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	fileHandle = [NSFileHandle fileHandleForWritingAtPath:appFilePath];
	if (fileHandle==nil) {
		return;
	}
    
    if (self.keyString) {
        [fileHandle truncateFileAtOffset:0];
        if (writer) {
            writer=[self rc4WithInput:writer key:self.keyString];
        }
        [fileHandle writeData:writer];
    }else {
        if ([@"1" isEqualToString:inMode]) {
//            mode = YES;//追加
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:writer];
        }else {
//            mode = NO;//重新写文件
            [fileHandle truncateFileAtOffset:0];
            [fileHandle writeData:writer];
        }
    }
	
 	[fileHandle closeFile];
}

-(void)seek:(NSString*)inPos{
	NSInteger seekLocation = (NSInteger)[inPos longLongValue];
    offset = seekLocation;
	//跳转到指定位置
	fileHandle = [NSFileHandle fileHandleForReadingAtPath:appFilePath];
	if (fileHandle==nil) {
		return;
	}
	[fileHandle seekToFileOffset:(long)seekLocation];
}
-(void)seekBeginOfFile{
	[self seek:0];
	
}
-(void)seekEndOfFile{
	fileHandle = [NSFileHandle fileHandleForReadingAtPath:appFilePath];
	if (fileHandle==nil) {
		return;
	}
	[fileHandle seekToEndOfFile];
}

-(NSData*)rc4WithInput:(NSData *)aData key:(NSString *)aKey{
    NSString *aInput=[[[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding] autorelease];
    
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        int is = [[iS objectAtIndex:i] intValue];
        UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        
        j = (j + is + ik)%256;
        NSNumber *temp = [iS objectAtIndex:i];
        [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        [iS replaceObjectAtIndex:j withObject:temp];
    }
    
    int i=0;
    j=0;
    
    NSString *result = aInput;
    NSData *resultData;
    for (short x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue]; 
        
        int t = (is_i+is_j) % 256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        
        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
        resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [iS release];
    [iK release];
    
    return resultData;
}

//读取字数
-(NSString*)read:(NSString*)len{ 
	long newlen = (long)[len longLongValue];
	fileHandle = [NSFileHandle fileHandleForReadingAtPath:appFilePath];
	NSData *getData;
	if (fileHandle==nil) {
		return nil;
	}
	long fileLength = [File getFileLength:appFilePath];
    if (self.keyString) {
        getData = [fileHandle readDataToEndOfFile];
        if (getData) {
            getData=[self rc4WithInput:getData key:self.keyString];
        }
    }else {
        if (newlen==-1 ||newlen>=fileLength) {
            getData = [fileHandle readDataToEndOfFile];
        }else {
            getData = [fileHandle readDataOfLength:newlen];
        }
    }
    
    NSString *resultString = [EUtility transferredString:getData];
	[fileHandle closeFile];
	return resultString;
}

-(long)getSize{
	//获得文件大小
	if ([File fileIsExist:appFilePath]) {
		 long fileSize =[File getFileLength:appFilePath]; 
		return fileSize;
	}
	return 0;
}
-(void)close{
	//关闭文件
}
-(NSString*)getFilePath{
	return  fileUrl;
}
-(long)getReaderOffset{
	return [self.OS_offset longValue];
}
//precent
-(NSString*)readPercent:(NSString*)inPercent Len:(NSString *)inLen{
	offset = [inPercent intValue]*[self getSize]/100;
	self.OS_offset = [NSNumber numberWithLong:offset];
	return [self readFilp:F_PAGE_PERCENT len:[inLen intValue]];
}
//pre
-(NSString*)readPre:(NSString*)inLen{
	return [self readFilp:F_PAGE_PRE len:[inLen intValue]];
}
//next
-(NSString*)readNext:(NSString*)inLen{
	return [self readFilp:F_PAGE_NEXT len:[inLen intValue]];
}
//filp
-(NSString*)readFilp:(int)inType len:(int)inLen{
	NSString *readString = nil;

	if (inLen<3) {
		return nil;
	}
	if (inType==F_PAGE_PRE) {
		if (offset==0) {
			OS_offset = [NSNumber numberWithLong:0];
			return nil;
		}
		offset = offset-[currentLength longValue] - inLen;
	}
	long fileLen = [self getSize];
	if (fileLen==0) {return nil;}
	if (offset>=fileLen) {return nil;}
	 
	if (inType ==F_PAGE_PERCENT) {
		if (fileLen-offset<=3) {
			offset = fileLen-3;
		}
	}

	if (offset<0) {
		offset = 0;
	}
	if (offset>=0) {
		[self seek:[NSString stringWithFormat:@"%ld",offset]];
	}
	NSData *readData = nil;
	int readLenth = inLen;
	if (fileHandle!=nil) {
		for (int i =0 ; i<6; i++) {
			readData = [fileHandle readDataOfLength:readLenth];
			readString = [[[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding] autorelease];
			if (readString!=nil) {
				offset +=[readData length]; 
				break;
			}else {
				readLenth-=1;
				[fileHandle seekToFileOffset:offset];
			}
		}
		int readLengthSuf = inLen;
		int offsetSuf = offset;
		if (readString==nil) {
			for (int j = 0; j<6; j++) {
				offsetSuf-=1;
				if (offsetSuf >=0) {
					[fileHandle seekToFileOffset:offsetSuf];
					readData = [fileHandle readDataOfLength:readLengthSuf];
					readString = [[[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding] autorelease];
					if(readString!=nil){
						offset =offsetSuf +[readData length];
						break;
					}
				}else {
					break;
				}
			}
		}
		int readLengthPre = inLen;
		int offsetPre = offset;
		if (readString == nil) {
			for (int i = 0; i<6; i++) {
				offsetPre -=1;
				if (offsetPre<0) {
					offsetPre = 0;
				}
				for (int j = 0; j<6; j++) {
					readLengthPre+=1;
					if (offsetPre>=0) {
						[fileHandle seekToFileOffset:offsetPre];
						readData = [fileHandle readDataOfLength:readLengthPre];
						readString = [[[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding] autorelease];
						if (readString!=nil) {
							offset = offsetPre+[readData length];
							break;	
						} 
						
					}
				}
				if (readString!=nil) {
					break;
				}
			}
		}
	}
	if (readData) {
		self.currentLength = [NSNumber numberWithLong:[readData length]];
	}
	self.OS_offset = [NSNumber numberWithLong:offset];
 	PluginLog(@"readString = %@",readString);
	//将读取到的数据中的换行换成<br>
	NSString *lTmp = [NSString stringWithFormat:@"%c",'\n'];
	NSString *resultStr = [readString stringByReplacingOccurrencesOfString:lTmp withString:@"<br/>&nbsp;&nbsp;"];
 	NSData *data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *finalString = [EUtility transferredString:data];
	return finalString;
}
//乱码
//-(BOOL)isMessyCode:(NSString *)inStr{
//	for (int i=0; i<inStr.length; i++) {
//		char c = [inStr characterAtIndex:i];
//		if (c == 0xfffd) {
//			return YES;
//		}
//	}
//	return NO;
//}
-(void)dealloc{
	[appFilePath release];
	appFilePath = nil;
	if (fileUrl) {
		[fileUrl release];
		fileUrl = nil;
	}
	[OS_offset release];
    if (keyString) {
        self.keyString=nil;
    }
	[super dealloc];
}
@end
