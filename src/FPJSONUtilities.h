//
//  FPJSONUtilities.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData * FPJSONEncode(id object, NSError **error);
id FPJSONDecode(NSData *data, NSError **error);