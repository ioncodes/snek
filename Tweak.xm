#import <BulletinBoard/BBBulletin.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.ioncodes.snekprefs.plist"

inline bool getPrefBool(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];
}

inline NSString* getPrefString(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] stringValue];
}

static void sendToServer(NSString* title, NSString* message, NSString* sectionID) {
	NSString *urlStr = getPrefString(@"tUrl");
	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *token = getPrefString(@"tPassword");

	NSMutableDictionary *payload = [NSMutableDictionary dictionary];
	[payload setObject:title forKey:@"title"];
	[payload setObject:message forKey:@"message"];
	[payload setObject:sectionID forKey:@"sectionID"];
	[payload setObject:token forKey:@"token"];

	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:jsonData];

	NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {}];

	[postDataTask resume];
}

/*
static void sendToSlack(NSString* title, NSString* message) {
	NSString *token = @"TOKEN";
	NSString *msg = [NSString stringWithFormat:@"%@: %@", title, message];
	NSString *urlStr = [NSString stringWithFormat:@"https://slack.com/api/chat.postMessage?token=%@&channel=iphone&text=%@&pretty=1", token, msg];

	NSURL *url = [NSURL URLWithString:urlStr]; // todo: move to preferences

	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"GET"];

	NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {}];

	[getDataTask resume];
}
*/

%group Tweak
%hook BBServer
- (void) publishBulletin:(BBBulletin*)bulletin destinations:(unsigned int)arg2 alwaysToLockScreen:(BOOL)arg3 {
	%orig;
	if(getPrefBool(@"tEnabled")) {
		[[[NSOperationQueue alloc] init] addOperationWithBlock:^{
			@try {
				NSString *title = bulletin.title;
				NSString *message = bulletin.message;
				NSString *sectionID = bulletin.sectionID;

				if(title == nil) { // a few applications don't have a title
					title = @"";
				}

				if(message == nil) {
					message = @"";
				}

				if(sectionID == nil) {
					sectionID = @"";
				}

				sendToServer(title, message, sectionID);
				// sendToSlack(title, message);
			} @catch (NSException *exception) {
				sendToServer(@"Error", @"Error", @"Error");
				// sendToSlack(@"Error", @"Error");
				NSLog(@"Error: %@", exception);
			}
		}];
	}
}
%end
%end

%ctor {
	@autoreleasepool {
		%init(Tweak);
	}
}