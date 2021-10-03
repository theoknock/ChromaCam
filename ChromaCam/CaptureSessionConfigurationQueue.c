//
//  CaptureSessionConfigurationQueue.c
//  ChromaCam
//
//  Created by Xcode Developer on 6/15/21.
//

#include <stdio.h>

#include "CaptureSessionConfigurationQueue.h"

dispatch_queue_t capture_session_configuration_queue;

dispatch_queue_t (^capture_session_configuration_queue_ref)(void) = ^ dispatch_queue_t (void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!capture_session_configuration_queue || capture_session_configuration_queue == NULL) {
            capture_session_configuration_queue = dispatch_queue_create_with_target("CaptureSessionConfigurationQueue", DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, dispatch_get_main_queue());
        }
    });

    return capture_session_configuration_queue;
};
