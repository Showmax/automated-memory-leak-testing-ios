# Automated memory leak testing

[https://tech.showmax.com/2019/02/automated-mem-leak-testing-ios/](Blog post on tech.showmax.com)

## Requirements

- Xcode installed or symlinked exactly at `/Applications/Xcode.app`

## Example

Start script that will run UI and detect memory leaks occurred during test run:

```
$ ./check_memoryleaks
```

Which results in:

```
Latest leaks:
 2x Malloc 32 Bytes
 1x UINavigationItem  ObjC  UIKitCore
 1x NumberGeneratorViewController  Swift  Leakmax  # <--- our leaking code
 1x CFDictionary  ObjC  CoreFoundation
 1x Malloc 48 Bytes
 1x NumberGenerator  Swift  Leakmax                # <--- our leaking code
 1x UITabBarItem  ObjC  UIKitCore
```