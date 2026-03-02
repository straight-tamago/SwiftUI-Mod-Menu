#import <Foundation/Foundation.h>
#import "wk_settings_bridge.h"

static NSString *WKSettingsPath(void) {
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [dir stringByAppendingPathComponent:@"wk_settings.plist"];
}

static NSMutableDictionary *WKLoadSettings(void) {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:WKSettingsPath()];
    if (![dict isKindOfClass:[NSDictionary class]]) { return [NSMutableDictionary dictionary]; }
    return [dict mutableCopy];
}

static void WKSaveSettings(NSDictionary *dict) {
    [dict writeToFile:WKSettingsPath() atomically:YES];
}

static NSString *WKKey(const char *key) {
    if (key == NULL) { return nil; }
    return [NSString stringWithUTF8String:key];
}

bool WKReadBool(const char *key, bool fallback) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return fallback; }
    NSNumber *value = WKLoadSettings()[nsKey];
    if (![value isKindOfClass:[NSNumber class]]) { return fallback; }
    return value.boolValue;
}

int WKReadInt(const char *key, int fallback) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return fallback; }
    NSNumber *value = WKLoadSettings()[nsKey];
    if (![value isKindOfClass:[NSNumber class]]) { return fallback; }
    return value.intValue;
}

double WKReadDouble(const char *key, double fallback) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return fallback; }
    NSNumber *value = WKLoadSettings()[nsKey];
    if (![value isKindOfClass:[NSNumber class]]) { return fallback; }
    return value.doubleValue;
}

const char *WKReadString(const char *key) {
    static NSString *cached = nil;
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return NULL; }
    NSString *value = WKLoadSettings()[nsKey];
    if (![value isKindOfClass:[NSString class]]) { return NULL; }
    cached = value;
    return cached.UTF8String;
}

const char *WKReadStringOrDefault(const char *key, const char *fallback) {
    const char *value = WKReadString(key);
    if (value != NULL) { return value; }
    return fallback;
}

bool WKHasKey(const char *key) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return false; }
    return WKLoadSettings()[nsKey] != nil;
}

void WKWriteBool(const char *key, bool value) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return; }
    NSMutableDictionary *dict = WKLoadSettings();
    dict[nsKey] = @(value);
    WKSaveSettings(dict);
}

void WKWriteInt(const char *key, int value) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return; }
    NSMutableDictionary *dict = WKLoadSettings();
    dict[nsKey] = @(value);
    WKSaveSettings(dict);
}

void WKWriteDouble(const char *key, double value) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return; }
    NSMutableDictionary *dict = WKLoadSettings();
    dict[nsKey] = @(value);
    WKSaveSettings(dict);
}

void WKWriteString(const char *key, const char *value) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil || value == NULL) { return; }
    NSString *nsValue = [NSString stringWithUTF8String:value];
    if (nsValue == nil) { return; }
    NSMutableDictionary *dict = WKLoadSettings();
    dict[nsKey] = nsValue;
    WKSaveSettings(dict);
}

void WKRemoveKey(const char *key) {
    NSString *nsKey = WKKey(key);
    if (nsKey == nil) { return; }
    NSMutableDictionary *dict = WKLoadSettings();
    [dict removeObjectForKey:nsKey];
    WKSaveSettings(dict);
}
