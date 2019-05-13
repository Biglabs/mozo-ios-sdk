//
//  MnemonicsSuggestionsInputAccessoryView.h
//
//  Created by Mikhail Nikanorov.
//

#import <UIKit/UIKit.h>
#import "MnemonicsItemViewUpdateProtocol.h"

#define UIColorFromHEX(hexValue)                                         \
        [UIColor colorWithRed:((CGFloat)((hexValue & 0xff0000) >> 16)) / 255.0 \
        green:((CGFloat)((hexValue & 0x00ff00) >> 8)) / 255.0  \
        blue:((CGFloat)((hexValue & 0x0000ff) >> 0)) / 255.0  \
        alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@class MnemonicsSuggestionsInputAccessoryViewDataSource;
@protocol MnemonicsSuggestionsInputAccessoryViewDelegate;

@interface MnemonicsSuggestionsInputAccessoryView : UIView <MnemonicsItemViewUpdateProtocol>
@property (nonatomic, weak, nullable) id <MnemonicsSuggestionsInputAccessoryViewDelegate> delegate;
- (void) setLast:(BOOL)last;
@end

@protocol MnemonicsSuggestionsInputAccessoryViewDelegate <NSObject>
- (void) mnemonicsSuggestions:(MnemonicsSuggestionsInputAccessoryView *)view didSelectWord:(NSString *)word;
- (void) mnemonicsSuggestionsDidCompletion:(MnemonicsSuggestionsInputAccessoryView *)view;
@end

NS_ASSUME_NONNULL_END
