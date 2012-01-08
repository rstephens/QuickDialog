//
//  Created by escoz on 11/1/11.
//

#import <objc/runtime.h>

NSDictionary * QRootElementJSONBuilderConversionDict;

@interface QRootElement ()
- (void)initializeMappings;

@end

@implementation QRootElement (JSONBuilder)

- (void)updateObject:(id)element withPropertiesFrom:(NSDictionary *)dict {
    for (NSString *key in dict.allKeys){
        if ([key isEqualToString:@"type"] || [key isEqualToString:@"sections"]|| [key isEqualToString:@"elements"])
            continue;

        id value = [dict valueForKey:key];
        if ([value isKindOfClass:[NSString class]] && [element respondsToSelector:NSSelectorFromString(key)]) {
            [element setValue:value forKey:key];
            if ([QRootElementJSONBuilderConversionDict objectForKey:key]!=nil) {
                [element setValue:[[QRootElementJSONBuilderConversionDict objectForKey:key] objectForKey:value] forKey:key];
            }
        } else if ([value isKindOfClass:[NSNumber class]]){
            [element setValue:value forKey:key];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [element setValue:value forKey:key];
        }
    }
}

- (QElement *)buildElementWithJson:(NSDictionary *)dict  {
    QElement *element = [[NSClassFromString([dict valueForKey:@"type"]) alloc] init];
    if (element==nil)
            return nil;
    [self updateObject:element withPropertiesFrom:dict];
    return element;
}

- (void)buildSectionWithJSON:(NSDictionary *)dict {
    QSection *sect = [[QSection alloc] init];
    [self updateObject:sect withPropertiesFrom:dict];
    [self addSection:sect];
    for (id element in (NSArray *)[dict valueForKey:@"elements"]){
       [sect addElement:[self buildElementWithJson:element] ];
    }
}

- (void)buildSectionsWithJSON:(NSDictionary *)dict {
    [self updateObject:self withPropertiesFrom:dict];
    for (id section in (NSArray *)[dict valueForKey:@"sections"]){
        [self buildSectionWithJSON:section];
    }
}

- (id)initWithJSONFile:(NSString *)jsonPath {
    self = [self initWithJSONFile:jsonPath andData:nil];
    return self;
}

- (id)initWithJSONFile:(NSString *)jsonPath andData:(id)data {
    self = [super init];
    
    Class JSONSerialization = objc_getClass("NSJSONSerialization");
    
    NSAssert(JSONSerialization != NULL, @"No JSON serializer available!");
    
    if (self!=nil){
        if (QRootElementJSONBuilderConversionDict==nil)
            [self initializeMappings];

        NSError *jsonParsingError = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonPath ofType:@"json"];
        NSDictionary *jsonRoot = [JSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&jsonParsingError];
        [self buildSectionsWithJSON:jsonRoot];
        if (data!=nil)
            [self bindToObject:data];
    }
    return self;
}

+ (BOOL)jsonAvailable {
    return objc_getClass("NSJSONSerialization") != NULL;
}

- (void)initializeMappings {
    QRootElementJSONBuilderConversionDict = [[NSDictionary alloc] initWithObjectsAndKeys:

                    [[NSDictionary alloc] initWithObjectsAndKeys:
                        [NSNumber numberWithInt:UITextAutocapitalizationTypeNone], @"None",
                                [NSNumber numberWithInt:UITextAutocapitalizationTypeWords], @"Words",
                                [NSNumber numberWithInt:UITextAutocapitalizationTypeSentences], @"Sentences",
                                [NSNumber numberWithInt:UITextAutocapitalizationTypeAllCharacters], @"AllCharacters",
                                nil], @"autocapitalizationType",

                    [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithInt:UITextAutocorrectionTypeDefault], @"Default",
                                    [NSNumber numberWithInt:UITextAutocorrectionTypeNo], @"No",
                                    [NSNumber numberWithInt:UITextAutocorrectionTypeYes], @"Yes",
                                    nil], @"autocorrectionType",

                    [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:UIKeyboardTypeDefault], @"Default",
                                    [NSNumber numberWithInt:UIKeyboardTypeASCIICapable], @"ASCIICapable",
                                    [NSNumber numberWithInt:UIKeyboardTypeNumbersAndPunctuation], @"NumbersAndPunctuation",
                                    [NSNumber numberWithInt:UIKeyboardTypeURL], @"URL",
                                    [NSNumber numberWithInt:UIKeyboardTypeNumberPad], @"NumberPad",
                                    [NSNumber numberWithInt:UIKeyboardTypePhonePad], @"PhonePad",
                                    [NSNumber numberWithInt:UIKeyboardTypeNamePhonePad], @"NamePhonePad",
                                    [NSNumber numberWithInt:UIKeyboardTypeEmailAddress], @"EmailAddress",
                                    [NSNumber numberWithInt:UIKeyboardTypeDecimalPad], @"DecimalPad",
                                    [NSNumber numberWithInt:UIKeyboardTypeTwitter], @"Twitter",
                                    [NSNumber numberWithInt:UIKeyboardTypeAlphabet], @"Alphabet",
                                    nil], @"keyboardType",

                    [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithInt:UIKeyboardAppearanceDefault], @"Default",
                                    [NSNumber numberWithInt:UIKeyboardAppearanceAlert], @"Alert",
                                    nil], @"keyboardAppearance",

                    [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:UIReturnKeyDefault], @"Default",
                                    [NSNumber numberWithInt:UIReturnKeyGo], @"Go",
                                    [NSNumber numberWithInt:UIReturnKeyGoogle], @"Google",
                                    [NSNumber numberWithInt:UIReturnKeyJoin], @"Join",
                                    [NSNumber numberWithInt:UIReturnKeyNext], @"Next",
                                    [NSNumber numberWithInt:UIReturnKeyRoute], @"Route",
                                    [NSNumber numberWithInt:UIReturnKeySearch], @"Search",
                                    [NSNumber numberWithInt:UIReturnKeySend], @"Send",
                                    [NSNumber numberWithInt:UIReturnKeyYahoo], @"Yahoo",
                                    [NSNumber numberWithInt:UIReturnKeyDone], @"Done",
                                    [NSNumber numberWithInt:UIReturnKeyEmergencyCall], @"EmergencyCall",
                                    nil], @"returnKeyType",

                    nil];
}


@end