# Automated memory leak testing

[Blog post with details explained](https://tech.showmax.com/2019/02/automated-mem-leak-testing-ios/)

## Requirements

- Xcode 11 installed or symlinked exactly at `/Applications/Xcode.app`

## Example

1) Open `check_memoryleaks` script and fill `SIMULATOR_NAME` variable with name of simulator that should be used.

```
SIMULATOR_NAME="iPhone 8"
```

2) Start script. It will run UI tests and detect memory leaks occurring during test run.

```
$ ./check_memoryleaks
```

3) Memory leak detected.

```
Latest leaks:

 21x Malloc 32 Bytes
 9x NSLayoutConstraint (ObjC Foundation)
 9x Malloc 16 Bytes
 8x Malloc 304 Bytes
 6x Malloc 48 Bytes
 5x Malloc 64 Bytes
 4x CALayer (ObjC QuartzCore)
 4x CALayerArray (ObjC QuartzCore)
 3x CFDictionary ((__NSCFDictionary) ObjC CoreFoundation)
 3x UITabBarItem (ObjC UIKitCore)
 3x Generator (Swift Leakmax)                                # <--- our leaking code
 3x UINavigationItem (ObjC UIKitCore)
 3x UITraitCollection (ObjC UIKitCore)
 3x _UILabelLayer (ObjC UIKitCore)
 3x GeneratorViewController (Swift Leakmax)                  # <--- our leaking code
 2x NSMutableArray ((__NSArrayM) ObjC CoreFoundation)
 2x CGColor (CFType CoreGraphics)
 1x UIView (ObjC UIKitCore)
 1x CATransformLayer (ObjC QuartzCore)
 1x Malloc 208 Bytes
 1x _UIViewLayoutEngineRelativeAlignmentRectOriginCache (ObjC UIKitCore)
```