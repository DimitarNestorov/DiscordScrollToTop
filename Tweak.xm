#import <UIKit/UIKit.h>

@interface DCDMessageViewController : UIViewController

@property BOOL isNearTop;

@property (nonatomic, strong, readwrite) UITableView *tableView;

@property (nonatomic, assign, readwrite, getter=isInverted) BOOL inverted;

@property (nonatomic, copy, readwrite) void (^onChatScrollPosition)(NSDictionary *);

- (NSNumber *)reactTag;

@end

static DCDMessageViewController *chatInstance;
static DCDMessageViewController *otherInstance;

%hook DCDMessageViewController

- (void)viewDidAppear:(BOOL)animated {
	%orig;

	if (self.inverted) {
		chatInstance = self;
	} else {
		otherInstance = self;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	%orig;

	if (self.inverted) {
		chatInstance = nil;
	} else {
		otherInstance = nil;
	}
}

%end

%hook UIStatusBarManager

- (void)handleTapAction:(id)arg1 {
	%orig;

	DCDMessageViewController *instance = otherInstance ?: chatInstance;

	if (!instance) return;

	UITableView *view = instance.tableView;

	if (instance == chatInstance) {
		instance.onChatScrollPosition(@{
			@"decelerating": [NSNumber numberWithInt:0],
			@"dragging": [NSNumber numberWithInt:1],
			@"isAtBottom": [NSNumber numberWithInt:0],
			@"isNearBottom": [NSNumber numberWithInt:0],
			@"isNearTop": [NSNumber numberWithInt:1],
			@"shouldShowJumpToPresent": [NSNumber numberWithInt:0],
			@"target": instance.reactTag,
		});
		[view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[view numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	} else {
		[view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

%end
