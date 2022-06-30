@import QuartzCore;

extern NSData *__nonnull CAEncodeLayerTreeWithInfo(CALayer *__nonnull rootLayer,
                                                   id<NSCoding> __nullable info);

extern BOOL CAMLEncodeLayerTreeToPathWithInfo(CALayer *__nonnull rootLayer,
                                              NSString *__nonnull path,
                                              id<NSCoding> __nullable info);
