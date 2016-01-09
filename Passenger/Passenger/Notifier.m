//
//  Notifier.m
//  Passenger
//
//  Created by Connor Myers on 12/29/15.
//  Copyright © 2015 Astral. All rights reserved.
//

#import "Notifier.h"
#import "notify.h"

@implementation Notifier

bool isLocked;

-(bool)isLocked {
    return isLocked;
}

-(void)registerAppforDetectLockState {
    
    int notify_token;
    
    notify_register_dispatch("com.apple.springboard.lockstate", &notify_token,dispatch_get_main_queue(), ^(int token) {
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        if(state == 0) {
           // NSLog(@"unlock device");
            isLocked = false;
        } else {
           // NSLog(@"lock device");
            isLocked = true;
        }
        
    });
}
@end
