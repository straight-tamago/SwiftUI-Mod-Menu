#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Read helpers / 読み取りヘルパー
bool WKReadBool(const char *key, bool fallback);
int WKReadInt(const char *key, int fallback);
double WKReadDouble(const char *key, double fallback);
const char *WKReadString(const char *key);
const char *WKReadStringOrDefault(const char *key, const char *fallback);
bool WKHasKey(const char *key);

// Write helpers / 書き込みヘルパー
void WKWriteBool(const char *key, bool value);
void WKWriteInt(const char *key, int value);
void WKWriteDouble(const char *key, double value);
void WKWriteString(const char *key, const char *value);
void WKRemoveKey(const char *key);

#ifdef __cplusplus
}
#endif
