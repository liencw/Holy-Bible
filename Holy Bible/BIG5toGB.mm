//
//  BIG5toGB.mm
//  Holy Bible
//
//  Created by Will on 12/2/28.
//  Copyright (c) 2012年 fishgold. All rights reserved.
//
#import "BIG5toGB.h"

NSStringEncoding gbEncoding=0x80000632;
NSStringEncoding big5Encoding_HK=0x80000A06;

@implementation Big5ToGB

- (Big5ToGB *) init{
    if(self=[super init]){
        memset(tbl, 0 , sizeof(tbl));
        [self readConvertedTbl];
    }
    return self;
}

- (NSInteger) mapBig5WithChar1:(NSInteger)char1 char2:(NSInteger) char2{
    if (char1>=161)
    {
        if (char2>=64 && char2<=126)
            return ((char1-161)*157+(char2-64))*2;
        else if (char2>=161 && char2<=254)
            return ((char1-161)*157+(char2-161)+63)*2;
    }
    return -1;
}


- (unsigned char *) big5ToGB:(unsigned char *)byteBig5 start:(NSInteger)start length:(NSInteger)len{
    int i,j;
    int i0,i1;
    unsigned char *byteGB=new unsigned char[len];
    //memset(byteGB, 0 , sizeof(byteGB));
    
    j=0;
    i=start;
    int offset=-1;
    while(i<len+start){
        i0=(byteBig5[i]>0)?byteBig5[i]:(256+byteBig5[i]);
        if (i<len+start-1)
            i1=(byteBig5[i+1]>0)?byteBig5[i+1]:(256+byteBig5[i+1]);
        else
            i1=0;
        offset=[self mapBig5WithChar1:i0 char2:i1];
        if(offset==-1) //English
        {
            byteGB[j]=byteBig5[i];
            i++;
            j++;
        }
        else //Big5
        {
            byteGB[j+1]=tbl[offset];
            byteGB[j]=tbl[offset+1];
            i+=2;
            j+=2;
        }
    }
    return byteGB;
}//big5ToGB()
- (NSString *)big5ToGB:(NSString *)big5{
    NSString *gbStr=big5;
    @try{
        NSInteger len=[big5 lengthOfBytesUsingEncoding:big5Encoding_HK];
        unsigned char *buffer=new unsigned char[len];
        //memset(buffer, 0, sizeof(buffer));
        NSRange rg=NSMakeRange(0, len);
        
        [big5 getBytes:(void *)buffer maxLength:(NSUInteger)len usedLength:(NSUInteger *)NULL encoding:(NSStringEncoding)big5Encoding_HK options:(NSStringEncodingConversionOptions)INT_MAX range:(NSRange)rg remainingRange:(NSRangePointer)NULL];
        unsigned char *byteGB=[self big5ToGB:(unsigned char *)buffer start:0 length:len];
        delete[] buffer;
        gbStr= [[NSString alloc] initWithBytes:byteGB length:len encoding:gbEncoding];
        delete byteGB;
    }
    @catch(NSException *ex){
        NSLog(@"big5ToGB %@: %@",big5,[ex reason]);
        return big5;
    }
    return [gbStr autorelease];
}


- (BOOL)readConvertedTbl{
    @try{
        NSString *grouppath = [[NSBundle mainBundle] pathForResource:@"Big5ToGB" ofType:@"tbl"];
        NSString *wholeStr=[NSString stringWithContentsOfFile:grouppath encoding: NSASCIIStringEncoding  error:nil];
        int i=0,value;
        NSArray *strs=[wholeStr componentsSeparatedByString:@","];
        for(NSString *itemStr in strs){
            NSScanner *scan=[NSScanner scannerWithString:itemStr];
            unsigned val;
            [scan scanHexInt:&val];
            value=val;
            tbl[i+1]=(unsigned char)(value/256);
            tbl[i]=(unsigned char)(value-tbl[i+1]*256);
            i=i+2;
        }
        return YES;
    }
    @catch(NSException *ex){
        NSLog(@"ReadConvertedTbl %@",[ex reason]);
        return NO;
    }
    return YES;
}//readConvertedTbl();

@end
