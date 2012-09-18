//
//  FPPreprocessor.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#ifndef FPInstagram_FPPreprocessor_h
#define FPInstagram_FPPreprocessor_h

#ifndef FPRELEASE_SAFELY
#define FPRELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#endif

#endif
