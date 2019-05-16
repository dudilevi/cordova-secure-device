/*
 Copyright 2016 André Vieira
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/********* cordova-secure-device.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import "secureDevice.h"
#import "UIDevice+PasscodeStatus.h"
#import "UIDevice+JBDetect.h"

@implementation secureDevice

- (void)pluginInitialize
{ 
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [self checkDevice];
 
}

- (void) onResume:(UIApplication *)application 
{
    [self checkDevice];
}

- (void) checkDevice
{
    BOOL jailbroken = [UIDevice currentDevice].isJB;
    LNPasscodeStatus status = [UIDevice currentDevice].passcodeStatus;
    BOOL checkPattern = ![(NSString* )[self.commandDelegate.settings objectForKey:@"checkpattern"] isEqualToString:@"false"];

    if (jailbroken || ( checkPattern && (status == LNPasscodeStatusDisabled || status == LNPasscodeStatusUnknown))) {
        
        NSString* alertMessage = @"אפליצקיה זו חסומה מלרוץ על מכשירים פרוצים.";
        NSString* customAlertCloseButtonText = [self.commandDelegate.settings objectForKey:@"secureplugindialogcloselabel"];
        NSString *alertCloseButtonText = customAlertCloseButtonText ? customAlertCloseButtonText : @"Close";
        
        if(jailbroken) {
            NSString* customAlertMessage = [self.commandDelegate.settings objectForKey:@"securepluginrooteddevicestring"];
            if(customAlertMessage) {
                alertMessage = [customAlertMessage copy];
            }
        } else {
            NSString* customAlertMessage = [self.commandDelegate.settings objectForKey:@"securepluginnolocksafetystring"];
            if(customAlertMessage) {
                alertMessage = [customAlertMessage copy];
            }
        }
        
        dispatch_async( dispatch_get_main_queue(), ^ {
            //Remove webView
            [self.webView removeFromSuperview];
            // Show Alert
            [self showAlert:alertMessage closeLabel:alertCloseButtonText];
        });
    }
}
/*
 * showAlert - Common method to instantiate the alert view for alert
 * Parameters:
 *  message       The alert view message.
 *  closeLabel    The label for the close button
 */
- (void)showAlert:(NSString*)message closeLabel:(NSString*)closeLabel
{
    
#ifdef __IPHONE_8_0
    if (NSClassFromString(@"UIAlertController")) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
            
            CGRect alertFrame = [UIScreen mainScreen].applicationFrame;
            
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                // swap the values for the app frame since it is now in landscape
                CGFloat temp = alertFrame.size.width;
                alertFrame.size.width = alertFrame.size.height;
                alertFrame.size.height = temp;
            }
            
            alertController.view.frame =  alertFrame;
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:closeLabel
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        exit(0);
                                    }]];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
#endif
        
        UIAlertView* alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil];
        
        [alertView addButtonWithTitle:closeLabel];
        
        [alertView show];
#ifdef __IPHONE_8_0
    }
#endif
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{	
    exit(0);
}

@end
