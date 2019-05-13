//
//  MnemonicsTextField.m
//
//  Created by Mikhail Nikanorov.
//

#import "MnemonicsTextField.h"

#import "MnemonicsSuggestionsInputAccessoryView.h"

@interface MnemonicsTextField ()
@property (nonatomic, strong) MnemonicsSuggestionsInputAccessoryView *suggestionsInputAccessoryView;
@end

@implementation MnemonicsTextField
@dynamic delegate;
@dynamic inputAccessoryView;

- (instancetype)init {
  self = [super init];
  if (self) {
    _showInputAccessoryView = NO;
    _correct = YES;
    [self _createInputAccessoryView];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType = UIReturnKeyDone;
      
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.textAlignment = NSTextAlignmentCenter;
  }
  return self;
}

- (void)addSubview:(UIView *)view {
  [super addSubview:view];
  
  if (@available(iOS 11.0, *)) { } else {
    if ([NSStringFromClass(view.class) isEqualToString:@"UITextFieldLabel"]) {
      UILabel *label = (UILabel *)view;
      label.font = self.font;
    }
  }
}

- (CGRect) textRectForBounds:(CGRect)bounds {
  CGRect rect = [super textRectForBounds:bounds];
  rect = CGRectInset(rect, 7.0, 2.0);
  return rect;
}

- (CGRect) placeholderRectForBounds:(CGRect)bounds {
  CGRect rect = [super placeholderRectForBounds:bounds];
  rect = CGRectInset(rect, 7.0, 2.0);
  return rect;
}

- (CGRect) editingRectForBounds:(CGRect)bounds {
  CGRect rect = [super editingRectForBounds:bounds];
  rect = CGRectInset(rect, 7.0, 2.0);
  return rect;
}

- (BOOL) becomeFirstResponder {
  if (_correct || [self.text length] == 0) {
      self.textColor = UIColorFromHEX(0x333333);
      //[UIColor colorWithRed:6.0/255.0 green:77.0/255.0 blue:214.0/255.0 alpha:1.0];
//    self.layer.borderColor = [UIColor colorWithRed:4.0/255.0 green:76.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
      self.layer.backgroundColor = [UIColor clearColor].CGColor;
//    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0;
    self.layer.cornerRadius = 8.0;
  } else {
    self.layer.borderColor = [UIColor clearColor].CGColor;
//    self.layer.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8].CGColor;
  }
  self.hidden = NO;
  return [super becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
  if ([self.text length] == 0) {
    self.hidden = YES;
  }
  if (_correct) {
    //  self.textColor = [UIColor blackColor];
    self.textColor = UIColorFromHEX(0x4e94f3);
  } else {
    self.textColor = UIColorFromHEX(0xf05454);
  }
//  self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
  self.layer.borderColor = [UIColor clearColor].CGColor;
  
  return [super resignFirstResponder];
}

- (void) deleteBackward {
  if ([self.text length] == 0) {
    [self.delegate textFieldDidTryDeleteEmptyText:self];
  } else {
    if (@available(iOS 12.0, *)) {
      [self setMarkedText:nil selectedRange:NSMakeRange(0, 0)];
    } else {
      [self setMarkedText:@"" selectedRange:NSMakeRange(0, 0)];
    }
    [self unmarkText];
    [super deleteBackward];
  }
}

- (void) tabCommand:(UIKeyCommand *)sender {
  [self.delegate textFieldDidFireTabCommand:self];
}

#pragma mark - Public

- (void) markAsCorrect {
  if (!_correct) {
    _correct = YES;
//    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
      self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.textColor = UIColorFromHEX(0x4e94f3);
    if (![self isFirstResponder]) {
//      self.textColor = [UIColor blackColor];
      self.layer.borderColor = [UIColor clearColor].CGColor;
      self.layer.borderWidth = 2.0;
      self.layer.cornerRadius = 8.0;
    } else {
//      self.textColor = [UIColor colorWithRed:6.0/255.0 green:77.0/255.0 blue:214.0/255.0 alpha:1.0];
//      self.layer.borderColor = [UIColor colorWithRed:4.0/255.0 green:76.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    }
    self.tintColor = self.textColor;
  }
  if ([super inputAccessoryView] == nil) {
    [self reloadInputViews];
  }
}

- (NSArray<UIKeyCommand *> *)keyCommands {
  return @[[UIKeyCommand keyCommandWithInput:@"\t" modifierFlags:0 action:@selector(tabCommand:)]];
}

- (void) markAsIncorrect {
  if (_correct) {
    _correct = NO;
    self.textColor = UIColorFromHEX(0xf05454);
      //[UIColor colorWithRed:214.0/255.0 green:6.0/255.0 blue:6.0/255.0 alpha:1.0];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    if ([self isFirstResponder]) {
        self.textColor = UIColorFromHEX(0x333333);
//      self.layer.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8].CGColor;
    }
    self.layer.borderWidth = 2.0;
    self.layer.cornerRadius = 8.0;
    self.tintColor = self.textColor;
  }
  if ([super inputAccessoryView] != nil) {
    [self reloadInputViews];
  }
}

#pragma mark - Override

- (__kindof MnemonicsSuggestionsInputAccessoryView *)inputAccessoryView {
  if (!_showInputAccessoryView) {
    return nil;
  }
  return self.suggestionsInputAccessoryView;
}

#pragma mark - Private

- (void) _createInputAccessoryView {
  MnemonicsSuggestionsInputAccessoryView *inputAccessoryView = [[MnemonicsSuggestionsInputAccessoryView alloc] init];;
  self.suggestionsInputAccessoryView = inputAccessoryView;
}

@end
