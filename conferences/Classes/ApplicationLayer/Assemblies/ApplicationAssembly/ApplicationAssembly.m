// Copyright (c) 2015 RAMBLER&Co
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ApplicationAssembly.h"

#import "ApplicationConfigurator.h"
#import "ApplicationConfiguratorImplementation.h"
#import "PushNotificationCenter.h"
#import "PushNotificationCenterImplementation.h"
#import "ServiceComponents.h"
#import "ThirdPartiesConfigurator.h"
#import "ThirdPartiesConfiguratorImplementation.h"
#import "SpotlightIndexerAssembly.h"
#import "CleanLaunchRouter.h"
#import "CleanLaunchAppDelegate.h"
#import "SpotlightAppDelegate.h"
#import "TabBarControllerFactoryImplementation.h"
#import "SpotlightLaunchHandler.h"
#import "EventLaunchRouter.h"
#import "SpeakerLaunchRouter.h"
#import "LectureLaunchRouter.h"

#import <RamblerAppDelegateProxy/RamblerAppDelegateProxy.h>

@implementation ApplicationAssembly

- (RamblerAppDelegateProxy *)applicationDelegateProxy {
    return [TyphoonDefinition withClass:[RamblerAppDelegateProxy class]
                          configuration:^(TyphoonDefinition *definition){
                              [definition injectMethod:@selector(addAppDelegates:)
                                            parameters:^(TyphoonMethod *method) {
                                                [method injectParameterWith:@[
                                                                              [self cleanStartAppDelegate],
                                                                              [self spotlightAppDelegate]
                                                                              ]];
                                            }];
                              definition.scope = TyphoonScopeSingleton;
                          }];
}

- (CleanLaunchAppDelegate *)cleanStartAppDelegate {
    return [TyphoonDefinition withClass:[CleanLaunchAppDelegate class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(applicationConfigurator)
                                                    with:[self applicationConfigurator]];
                              [definition injectProperty:@selector(thirdPartiesConfigurator)
                                                    with:[self thirdPartiesConfigurator]];
                              [definition injectProperty:@selector(cleanStartRouter)
                                                    with:[self cleanStartRouter]];
                              [definition injectProperty:@selector(indexerMonitor)
                                                    with:[self.spotlightIndexerAssembly indexerMonitor]];
                              [definition injectProperty:@selector(spotlightCoreDataStackCoordinator)
                                                    with:[self.spotlightIndexerAssembly spotlightCoreDataStackCoordinator]];
    }];
}

- (SpotlightAppDelegate *)spotlightAppDelegate {
    return [TyphoonDefinition withClass:[SpotlightAppDelegate class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithLaunchHandlers:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:@[
                                                                                     [self eventLaunchHandler],
                                                                                     [self speakerLaunchHandler],
                                                                                     [self lectureLaunchHandler]
                                                                                     ]];
                                              }];
                          }];
}

- (SpotlightLaunchHandler *)eventLaunchHandler {
    return [TyphoonDefinition withClass:[SpotlightLaunchHandler class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithObjectTransformer:dataCardLaunchRouter:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self.spotlightIndexerAssembly eventObjectTransformer]];
                                                  [initializer injectParameterWith:[self eventLaunchRouter]];
                                              }];
                          }];
}

- (SpotlightLaunchHandler *)speakerLaunchHandler {
    return [TyphoonDefinition withClass:[SpotlightLaunchHandler class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithObjectTransformer:dataCardLaunchRouter:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self.spotlightIndexerAssembly speakerObjectTransformer]];
                                                  [initializer injectParameterWith:[self speakerLaunchRouter]];
                                              }];
                          }];
}

- (SpotlightLaunchHandler *)lectureLaunchHandler {
    return [TyphoonDefinition withClass:[SpotlightLaunchHandler class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithObjectTransformer:dataCardLaunchRouter:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self.spotlightIndexerAssembly lectureObjectTransformer]];
                                                  [initializer injectParameterWith:[self lectureLaunchRouter]];
                                              }];
                          }];
}

- (id <ApplicationConfigurator>)applicationConfigurator {
    return [TyphoonDefinition withClass:[ApplicationConfiguratorImplementation class]];
}

- (id <PushNotificationCenter>)pushNotificationCenter {
    return [TyphoonDefinition withClass:[PushNotificationCenterImplementation class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(pushNotificationService)
                                                    with:[self.serviceComponents pushNotificationService]];
                          }];
}

- (id <ThirdPartiesConfigurator>)thirdPartiesConfigurator {
    return [TyphoonDefinition withClass:[ThirdPartiesConfiguratorImplementation class]];
}

#pragma mark - StartUpSystem

- (CleanLaunchRouter *)cleanStartRouter {
    return [TyphoonDefinition withClass:[CleanLaunchRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithTabBarControllerFactory:window:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self tabBarControllerFactory]];
                                                  [initializer injectParameterWith:[self mainWindow]];
                                              }];
                          }];
}

- (EventLaunchRouter *)eventLaunchRouter {
    return [TyphoonDefinition withClass:[EventLaunchRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithTabBarControllerFactory:window:storyboard:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self tabBarControllerFactory]];
                                                  [initializer injectParameterWith:[self mainWindow]];
                                                  [initializer injectParameterWith:[self eventStoryboard]];
                                              }];
                          }];
}

- (SpeakerLaunchRouter *)speakerLaunchRouter {
    return [TyphoonDefinition withClass:[SpeakerLaunchRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithTabBarControllerFactory:window:storyboard:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self tabBarControllerFactory]];
                                                  [initializer injectParameterWith:[self mainWindow]];
                                                  [initializer injectParameterWith:[self speakerStoryboard]];
                                              }];
                          }];
}

- (LectureLaunchRouter *)lectureLaunchRouter {
    return [TyphoonDefinition withClass:[LectureLaunchRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithTabBarControllerFactory:window:storyboard:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self tabBarControllerFactory]];
                                                  [initializer injectParameterWith:[self mainWindow]];
                                                  [initializer injectParameterWith:[self lectureStoryboard]];
                                              }];
                          }];
}

- (TabBarControllerFactoryImplementation *)tabBarControllerFactory {
    return [TyphoonDefinition withClass:[TabBarControllerFactoryImplementation class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(factoryWithStoryboard:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[self mainStoryboard]];
                                              }];
                          }];
}

- (UIStoryboard *)mainStoryboard {
    return [TyphoonDefinition withClass:[TyphoonStoryboard class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(storyboardWithName:factory:bundle:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:@"Main"];
                                                  [initializer injectParameterWith:self];
                                                  [initializer injectParameterWith:[NSBundle mainBundle]];
                                              }];
                          }];
}

- (UIStoryboard *)eventStoryboard {
    return [TyphoonDefinition withClass:[TyphoonStoryboard class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(storyboardWithName:factory:bundle:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:@"Event"];
                                                  [initializer injectParameterWith:self];
                                                  [initializer injectParameterWith:[NSBundle mainBundle]];
                                              }];
                          }];
}

- (UIStoryboard *)speakerStoryboard {
    return [TyphoonDefinition withClass:[TyphoonStoryboard class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(storyboardWithName:factory:bundle:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:@"SpeakerInfo"];
                                                  [initializer injectParameterWith:self];
                                                  [initializer injectParameterWith:[NSBundle mainBundle]];
                                              }];
                          }];
}

- (UIStoryboard *)lectureStoryboard {
    return [TyphoonDefinition withClass:[TyphoonStoryboard class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(storyboardWithName:factory:bundle:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:@"Lecture"];
                                                  [initializer injectParameterWith:self];
                                                  [initializer injectParameterWith:[NSBundle mainBundle]];
                                              }];
                          }];
}

- (UIWindow *)mainWindow {
    return [TyphoonDefinition withClass:[UIWindow class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition useInitializer:@selector(initWithFrame:)
                                              parameters:^(TyphoonMethod *initializer) {
                                                  [initializer injectParameterWith:[NSValue valueWithCGRect:[[UIScreen mainScreen] bounds]]];
                                              }];
                              definition.scope = TyphoonScopeSingleton;
                          }];
}

@end
