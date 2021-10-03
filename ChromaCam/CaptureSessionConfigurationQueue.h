//
//  CaptureSessionConfigurationQueue.h
//  ChromaCam
//
//  Created by Xcode Developer on 6/15/21.
//

#ifndef CaptureSessionConfigurationQueue_h
#define CaptureSessionConfigurationQueue_h

#include <stdio.h>
#include <dispatch/dispatch.h>

extern dispatch_queue_t capture_session_configuration_queue;
extern dispatch_queue_t (^capture_session_configuration_queue_ref)(void);

#endif /* CaptureSessionConfigurationQueue_h */
