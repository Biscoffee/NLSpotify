//
//  NLSectionViewModel.m
//  NLSpotify
//
//  Created by 吴桐 on 2025/12/13.
//

#import "NLSectionViewModel.h"

@implementation NLSectionViewModel

- (instancetype)initWithStyle:(NLHomeSectionStyle)style title:(NSString *)title items:(NSArray *)items {
  self = [super init];
  if (self) {
    _style = style;
    _title = title;
    _items = items;
  }
  return self;
}

+(instancetype) sectionWithStyle:(NLHomeSectionStyle)style title:(NSString *)title items:(NSArray *)items {
  return [[self alloc] initWithStyle:style title:title items:items];
}

@end
