//
//  SWWindow.m
//  Switch
//
//  Created by Scott Perry on 02/21/13.
//  Copyright © 2013 Scott Perry.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "SWWindow.h"

#import <Haxcessibility/Haxcessibility.h>
#import <Haxcessibility/HAXElement+Protected.h>

#import "SWApplication.h"


@implementation SWWindow

+ (instancetype)windowWithDescription:(NSDictionary *)description;
{
    return [[self alloc] initWithDescription:description];
}

- (instancetype)initWithDescription:(NSDictionary *)description;
{
    if (!(self = [super init])) { return nil; }
    
    if (!description) {
        return nil;
    }

    _windowDescription = [description copy];
    _application = [SWApplication applicationWithPID:[[self.windowDescription objectForKey:(NSString *)kCGWindowOwnerPID] intValue] name:[self.windowDescription objectForKey:(NSString *)kCGWindowOwnerName]];
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone;
{
    Check(!zone);
    return self;
}

- (NSUInteger)hash;
{
    return self.windowID;
}

- (BOOL)isEqual:(id)object;
{
    return ([object isKindOfClass:[self class]] && [[self windowDescription] isEqual:[object windowDescription]]);
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%p <%u (%@)>", self, self.windowID, self.name];
}

- (BOOL)isRelatedToLowerWindow:(SWWindow *)window;
{
    NSParameterAssert(window.application.canBeActivated);
    
    if (!self.application.canBeActivated) {
        return YES;
    }
    
    // Windows belonging to different applications are unrelated.
    if (![self.application isEqual:window.application]) {
        return NO;
    }

    // Powerbox (for example) names its windows, but cannot be activated.
    if (self.name.length && window.name.length) {
        return NO;
    }
    
    #pragma message "Going to need a better Tweetbot-specific rule here for when an image opens within the frame of the main window…"
    Check(self.application);
    Check(self.application.name);
    if ([self.application.name isEqualToString:@"Tweetbot"] && ![self enclosedByWindow:window]) {
        return NO;
    }
    
    return YES;
}

- (NNVec2)offsetOfCenterToCenterOfWindow:(SWWindow *)window;
{
    NSRect selfBounds = self.frame;
    NSRect windowBounds = window.frame;
    
    return (NNVec2){
        .x = ((windowBounds.origin.x + (windowBounds.size.width / 2.0)) - (selfBounds.origin.x + (selfBounds.size.width / 2.0))),
        .y = ((windowBounds.origin.y + (windowBounds.size.height / 2.0)) - (selfBounds.origin.y + (selfBounds.size.height / 2.0)))
    };
}

- (NSSize)sizeDifferenceFromWindow:(SWWindow *)window;
{
    NSRect selfBounds = self.frame;
    NSRect windowBounds = window.frame;
    
    return (NSSize){
        .width = selfBounds.size.width - windowBounds.size.width,
        .height = selfBounds.size.height - windowBounds.size.height
    };
}

- (BOOL)enclosedByWindow:(SWWindow *)window;
{
    NNVec2 c2cOffset = [self offsetOfCenterToCenterOfWindow:window];
    NNVec2 absC2COffset = (NNVec2){ .x = fabs(c2cOffset.x), .y = fabs(c2cOffset.y) };
    NSSize sizeDifference = [window sizeDifferenceFromWindow:self];
    
    return sizeDifference.width > absC2COffset.x * 2.0 && sizeDifference.height > absC2COffset.y * 2.0;
}

#pragma mark Dynamic accessors

- (NSRect)frame;
{
    CGRect result = {{},{}};
    bool success = CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)[self.windowDescription objectForKey:(NSString *)kCGWindowBounds], &result);
    BailUnless(success, ((NSRect){{0.0,0.0},{0.0,0.0}}));
    return result;
}

- (NSString *)name;
{
    return [self.windowDescription objectForKey:(__bridge NSString *)kCGWindowName];
}

- (CGWindowID)windowID;
{
    return (CGWindowID)[[self.windowDescription objectForKey:(__bridge NSString *)kCGWindowNumber] unsignedLongValue];
}

@end
