// Recolor an app icon into the title hue. YBar can grey a color image, but it
// cannot tint one, so the bar draws this bitmap instead.
#import <AppKit/AppKit.h>

static int fail(const char *message) {
  fprintf(stderr, "tint_app_icon: %s\n", message);
  return 1;
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    if (argc != 6) {
      return fail("usage: tint_app_icon <bundle-path> <out.png> <r> <g> <b>");
    }

    NSString *bundle = [NSString stringWithUTF8String:argv[1]];
    NSString *out = [NSString stringWithUTF8String:argv[2]];
    int red = atoi(argv[3]);
    int green = atoi(argv[4]);
    int blue = atoi(argv[5]);

    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:bundle];
    if (icon == nil) {
      return fail("no icon");
    }

    const NSInteger side = 64;
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL
                      pixelsWide:side
                      pixelsHigh:side
                   bitsPerSample:8
                 samplesPerPixel:4
                        hasAlpha:YES
                        isPlanar:NO
                  colorSpaceName:NSDeviceRGBColorSpace
                     bytesPerRow:side * 4
                    bitsPerPixel:32];
    if (rep == nil) {
      return fail("bitmap");
    }

    NSGraphicsContext *gc = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:gc];
    [icon drawInRect:NSMakeRect(0, 0, side, side)];
    [gc flushGraphics];
    [NSGraphicsContext restoreGraphicsState];

    unsigned char *bytes = [rep bitmapData];
    NSInteger rowBytes = [rep bytesPerRow];
    // Little-endian 32-bit reps store BGRA. The default 32-bit rep is RGBA.
    BOOL bgra = ([rep bitmapFormat] & NSBitmapFormatThirtyTwoBitLittleEndian) != 0;
    for (NSInteger y = 0; y < side; y++) {
      unsigned char *row = bytes + y * rowBytes;
      for (NSInteger x = 0; x < side; x++) {
        unsigned char *px = row + x * 4;
        int sr = bgra ? px[2] : px[0];
        int sg = px[1];
        int sb = bgra ? px[0] : px[2];
        int luma = (2126 * sr + 7152 * sg + 722 * sb) / 10000;
        // Keep the icon's alpha and its light-to-dark shape. Bright pixels
        // land on the title color; darker pixels are the same hue, dimmer.
        int cr = red * luma / 255;
        int cg = green * luma / 255;
        int cb = blue * luma / 255;
        if (bgra) {
          px[0] = (unsigned char)cb;
          px[1] = (unsigned char)cg;
          px[2] = (unsigned char)cr;
        } else {
          px[0] = (unsigned char)cr;
          px[1] = (unsigned char)cg;
          px[2] = (unsigned char)cb;
        }
      }
    }

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bytes, (size_t)(rowBytes * side), NULL);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo info = bgra
        ? (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
        : kCGImageAlphaPremultipliedLast;
    CGImageRef cg = CGImageCreate((size_t)side, (size_t)side, 8, 32, (size_t)rowBytes,
                                  space, info, provider, NULL, false, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(space);
    NSBitmapImageRep *encoded = cg ? [[NSBitmapImageRep alloc] initWithCGImage:cg] : nil;
    if (cg) CGImageRelease(cg);
    NSData *png = [encoded representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    NSString *dir = [out stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    if (png == nil || ![png writeToFile:out atomically:YES]) {
      return fail("write");
    }
    return 0;
  }
}
