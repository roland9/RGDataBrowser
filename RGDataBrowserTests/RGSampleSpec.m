//
//  RGSampleSpec.m
//  RGDataBrowser
//
//  Created by Roland on 13/02/2014.
//  Copyright (c) 2014 mapps. All rights reserved.
//
#import "Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 16;
        NSUInteger b = 26;
        [[theValue(a + b) should] equal:theValue(42)];
    });
});

SPEC_END