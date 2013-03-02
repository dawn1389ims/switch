//
//  NNSwitcher.h
//  Switch
//
//  Created by Scott Perry on 03/01/13.
//  Copyright © 2013 Scott Perry.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import "NNWindowStore.h"


@class NNSwitcher;


@protocol NNSwitcherDelegate <NSObject>

- (void)switcher:(NNSwitcher *)switcher didUpdateIndex:(unsigned)index;
- (void)switcher:(NNSwitcher *)switcher didUpdateWindowList:(NSArray *)windows;
- (void)switcher:(NNSwitcher *)switcher contentsOfWindowDidChange:(NNWindowData *)window;

@end


@interface NNSwitcher : NSObject <NNWindowStoreDelegate>

@property (nonatomic, assign) unsigned index;
@property (nonatomic, readonly) NSArray *windows;
@property (nonatomic, weak) id<NNSwitcherDelegate> delegate;

@end