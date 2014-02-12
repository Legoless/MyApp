MyApp
=====

A simple and elegant iOS 7 **App.net** client for iPhone, coded for quick practice. It displays unified stream of posts of logged in user in similar way as TweetBot does it for Twitter.

Features
=====
- Beautiful design inspired by TweetBot
- Login over OAuth protocol to App.net
- Real-time streaming of unified posts (refreshes when new post appears)
- Infinite scrolling (posts continue to load)
- TableViewCells of dynamic height
- Clickable links on posts

View Controllers
=====
- **LoginOAuthVC** - Handles representing login sheet to the user and saving of authorized users.
- **StreamVC** - Handles representing and refreshing the list of posts in real time.

Todo list
=====
- No logout button - *Turn off network connection to logout and restart the application.*
- Network connection handling - *Connection loss requires hard restart of the application.*

Libraries
=====
- **ADNKit** - Handles asynchronous requests to **App.net** API, built on top of `AFNetworking`.
- **AFNetworking** - Modern networking library, used by `ADNKit`, includes JSON parsing capabilities.
- **M13ProgressSuite** - Displays different progress views, including the ring intermediate progress view.
- **Reveal-iOS-SDK** - Used only for debugging errors in layout.
- **SDWebImage** - Used to load images of avatars from provided URL using a cache.
- **SSKeychain** - Used to securely store App.net access token, as recommended by documentation.
- **SVPullToRefresh** - Used to add simple infinite loading of posts.

