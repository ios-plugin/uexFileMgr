/**
 *
 *	@file   	: uexFileHashCalculator.m  in EUExFileMgr
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/24
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


#import "uexFileHashCalculator.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AppCanKit/ACEXTScope.h>

typedef int (*FileHashInitFunction)   (uint8_t *hashObjectPointer[]);
typedef int (*FileHashUpdateFunction) (uint8_t *hashObjectPointer[], const void *data, CC_LONG len);
typedef int (*FileHashFinalFunction)  (unsigned char *md, uint8_t *hashObjectPointer[]);







@interface uexFileHashCalculator()
@property (nonatomic,assign) FileHashInitFunction initFunction;
@property (nonatomic,assign) FileHashUpdateFunction updateFunction;
@property (nonatomic,assign) FileHashFinalFunction finalFunction;
@property (nonatomic,assign) size_t digestLength;
@property (nonatomic,assign) size_t contextSize;
@end



static const size_t kFileHashDefaultChunkSizeForReadingData = 4096;


@implementation uexFileHashCalculator


- (instancetype)initWithInitFunction:(FileHashInitFunction)initFunction
                      updateFunction:(FileHashUpdateFunction)updateFunction
                       finalFunction:(FileHashFinalFunction)finalFunction
                        digestLength:(size_t)digestLength
                         contextSize:(size_t)contextSize{
    self = [super init];
    if (self) {
        _initFunction = initFunction;
        _updateFunction = updateFunction;
        _finalFunction = finalFunction;
        _digestLength = digestLength;
        _contextSize = contextSize;
    }
    return self;
}


+ (instancetype)MD5Calculator{
    return [[self alloc] initWithInitFunction:(FileHashInitFunction)&CC_MD5_Init
                               updateFunction:(FileHashUpdateFunction)&CC_MD5_Update
                                finalFunction:(FileHashFinalFunction)&CC_MD5_Final
                                 digestLength:CC_MD5_DIGEST_LENGTH
                                  contextSize:sizeof(CC_MD5_CTX)
                            ];
}

+ (instancetype)SHA1Calculator{
    return [[self alloc] initWithInitFunction:(FileHashInitFunction)&CC_SHA1_Init
                               updateFunction:(FileHashUpdateFunction)&CC_SHA1_Update
                                finalFunction:(FileHashFinalFunction)&CC_SHA1_Final
                                 digestLength:CC_SHA1_DIGEST_LENGTH
                                  contextSize:sizeof(CC_SHA1_CTX)
                            ];
}




- (nullable NSString *)hashOfFileAtPath:(NSString *)path{
    if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        return nil;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    [handle seekToFileOffset:0];
    if (!handle) {
        return nil;
    }
    @onExit{
        [handle closeFile];
    };
    
    
    uint8_t *ctx[self.contextSize];
    uint8_t **ctxPointer = (uint8_t **)&ctx;
    self.initFunction(ctxPointer);
    BOOL hasMoreData = YES;
    while (hasMoreData) {
        @try {
            NSData *data = [handle readDataOfLength:kFileHashDefaultChunkSizeForReadingData];
            if (data.length == 0) {
                hasMoreData = NO;
            }else{
                self.updateFunction(ctxPointer,data.bytes,(CC_LONG)data.length);
            }

        } @catch (NSException *exception) {
            ACLogError(@"hash error: %@, details: %@",exception.reason,exception.userInfo);
            return nil;
        } @finally {}
    }

    
    unsigned char digest[self.digestLength];
    self.finalFunction (digest,ctxPointer);
    NSMutableString *result = [NSMutableString string];
    for (size_t i = 0; i < self.digestLength; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return [result copy];
}




@end
