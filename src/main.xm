#import <Foundation/Foundation.h>

#import "wk_settings_bridge.h"
#import "patch.h"
#import "dobby.h"

extern "C" void SwiftToC(int value) {
    NSLog(@"[SwiftUI_Mod_Menu] SwiftToC called from Swift: %d", value);
}

bool (*_GetInvincibleEnabled)(void);
bool GetInvincibleEnabled(void) {
    bool invincible_orig = _GetInvincibleEnabled();
    bool invincible_override = WKReadBool("invincible_enabled", false);
    NSLog(@"[SwiftUI_Mod_Menu] invincible_orig=%d invincible_override=%d", invincible_orig ? 1 : 0, invincible_override ? 1 : 0);
    return invincible_override;
}

extern "C" void init_main(void) {
    // DobbyHook((void *)getRealOffset(0x100000000), (void *)GetInvincibleEnabled, (void **)&_GetInvincibleEnabled);
}
