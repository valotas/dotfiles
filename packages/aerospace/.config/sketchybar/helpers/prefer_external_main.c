#include <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  CGDisplayCount count = 0;
  if (CGGetActiveDisplayList(0, NULL, &count) != kCGErrorSuccess || count == 0) {
    return 0;
  }

  CGDirectDisplayID *ids = calloc(count, sizeof(*ids));
  if (!ids) {
    return 1;
  }
  if (CGGetActiveDisplayList(count, ids, &count) != kCGErrorSuccess) {
    free(ids);
    return 1;
  }

  CGDirectDisplayID external = kCGNullDirectDisplay;
  for (CGDisplayCount i = 0; i < count; i++) {
    if (!CGDisplayIsBuiltin(ids[i])) {
      external = ids[i];
      break;
    }
  }

  if (external == kCGNullDirectDisplay || CGMainDisplayID() == external) {
    free(ids);
    return 0;
  }

  CGRect external_bounds = CGDisplayBounds(external);
  CGDisplayConfigRef config = NULL;
  if (CGBeginDisplayConfiguration(&config) != kCGErrorSuccess) {
    free(ids);
    return 1;
  }

  for (CGDisplayCount i = 0; i < count; i++) {
    CGRect bounds = CGDisplayBounds(ids[i]);
    int32_t x = (int32_t)(bounds.origin.x - external_bounds.origin.x);
    int32_t y = (int32_t)(bounds.origin.y - external_bounds.origin.y);
    CGConfigureDisplayOrigin(config, ids[i], x, y);
  }

  CGError complete = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
  free(ids);
  return complete == kCGErrorSuccess ? 0 : 1;
}
