//
//  SWPreferencesService.m
//  Switch
//
//  Created by Scott Perry on 10/20/13.
//  Copyright © 2013 Scott Perry.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "SWPreferencesService.h"

#import <NNKit/NNService+Protected.h>

#import "SWEventManager.h"
#import "SWHotKey.h"
#import "SWPreferencesWindowController.h"


static NSString *kNNFirstLaunchKey = @"firstLaunch";


@interface SWPreferencesService () <SWEventManagerSubscriber>

@property (nonatomic, strong) SWPreferencesWindowController *preferencesWindowController;

@end


@implementation SWPreferencesService

#pragma mark NNService

- (NNServiceType)serviceType;
{
    return NNServiceTypePersistent;
}

- (Protocol *)subscriberProtocol;
{
    return @protocol(SWPreferencesServiceDelegate);
}

- (NSSet *)dependencies;
{
    return [NSSet setWithArray:@[[SWEventManager class]]];
}

- (void)startService;
{
    [super startService];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:self._defaultValues];
    
#   if DEBUG
    {
        BOOL resetDefaults = NO;
        
        if (resetDefaults) {
            for (NSString *key in self._defaultValues.allKeys) {
                [defaults removeObjectForKey:key];
            }
        }
    }
#   endif
    
    // TODO: When these become customizable, they will become fields in the app's preferences.
    SWEventManager *keyManager = [SWEventManager sharedService];
    [keyManager registerHotKey:[SWHotKey hotKeyWithKeycode:kVK_Tab modifiers:SWHotKeyModifierOption] forEvent:SWEventManagerEventTypeInvoke];
    [keyManager registerHotKey:[SWHotKey hotKeyWithKeycode:kVK_Tab modifiers:(SWHotKeyModifierOption | SWHotKeyModifierShift)] forEvent:SWEventManagerEventTypeDecrement];
    [keyManager registerHotKey:[SWHotKey hotKeyWithKeycode:kVK_ANSI_W modifiers:SWHotKeyModifierOption] forEvent:SWEventManagerEventTypeCloseWindow];
    [keyManager registerHotKey:[SWHotKey hotKeyWithKeycode:kVK_Escape modifiers:SWHotKeyModifierOption] forEvent:SWEventManagerEventTypeCancel];
    [keyManager registerHotKey:[SWHotKey hotKeyWithKeycode:kVK_ANSI_Comma modifiers:SWHotKeyModifierOption] forEvent:SWEventManagerEventTypeShowPreferences];
   
    self.preferencesWindowController = [[SWPreferencesWindowController alloc] initWithWindowNibName:@"SWPreferencesWindowController"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kNNFirstLaunchKey]) {
        [self setObject:@NO forKey:kNNFirstLaunchKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPreferencesWindow:self];
        });
    }

    [defaults synchronize];
    
    [[NNServiceManager sharedManager] addObserver:self forService:[SWEventManager class]];
}

- (void)stopService;
{
    [[NNServiceManager sharedManager] removeObserver:self forService:[SWEventManager class]];
    
    [super stopService];
}

#pragma mark SWEventManagerSubscriber

- (oneway void)eventManager:(SWEventManager *)manager didProcessKeyForEventType:(SWEventManagerEventType)eventType;
{
    if (eventType == SWEventManagerEventTypeShowPreferences) {
        [self showPreferencesWindow:manager];
    }
}

#pragma mark SWPreferencesService

- (void)showPreferencesWindow:(id)sender;
{
    [self.preferencesWindowController showWindow:sender];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.preferencesWindowController.window makeKeyAndOrderFront:sender];
}

- (void)setObject:(id)object forKey:(NSString *)key;
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [(id<SWPreferencesServiceDelegate>)self.subscriberDispatcher preferencesService:self didSetValue:object forKey:key];
}

- (id)objectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark Internal

- (NSDictionary *)_defaultValues;
{
    static NSDictionary *_defaultValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultValues = @{
            kNNFirstLaunchKey : @YES,
        };
    });
    return _defaultValues;
}

@end