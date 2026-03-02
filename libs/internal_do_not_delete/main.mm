// main.mm
// ObjC/C++ constructor entry for Swift loader.
// Swift ローダー呼び出し用の ObjC/C++ コンストラクタエントリ。

#import <UIKit/UIKit.h>
extern "C" void init_main(void);

@interface Loader : NSObject
+ (void)setup;
@end

static void didFinishLaunching(CFNotificationCenterRef center, void *observer,
                               CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Loader setup];

        init_main();
    });
}

extern "C" void _logos_ctor() __attribute__((constructor));
void _logos_ctor() {
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching,
        (CFStringRef)UIApplicationDidFinishLaunchingNotification,
        NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
