#import <BulletinBoard/BBBulletin.h>

static void sendToServer(NSString* title, NSString* message) {
	NSURL *url = [NSURL URLWithString:@"http://snek.ioncodes.com/notify"]; // todo: move to preferences

	NSMutableDictionary *payload = [NSMutableDictionary dictionary];
	[payload setObject:title forKey:@"title"];
	[payload setObject:message forKey:@"message"];
	[payload setObject:@"YOUR_TOKEN" forKey:@"token"]; // todo: move to preferences

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

%group Tweak
%hook BBServer
- (void) publishBulletin:(BBBulletin*)bulletin destinations:(unsigned int)arg2 alwaysToLockScreen:(BOOL)arg3 {
	%orig;
	[[[NSOperationQueue alloc] init] addOperationWithBlock:^{
		@try {
			NSString *title = bulletin.title;
			NSString *message = bulletin.message;

			if(title == nil) { // a few applications don't have a title
				title = @"";
			}

			sendToServer(title, message);
		} @catch (NSException *exception) {
			sendToServer(@"Error", @"Error");
			NSLog(@"Error: %@", exception);
		}
	}];
}
%end
%end

%ctor {
	@autoreleasepool {
		%init(Tweak);
	}
}