## Send As POST
Send As POST is an app for iOS and macOS that adds a share extension to images and web pages.

Sharing via Send as POST will create a POST request with these parameters:

For images:

- `image`: the image data
- `caption` (optional): the text provided in the share card.

For links:

- `url`: the URL of the page
- `quote` (optional): the highlighted text on the page, if any
- `comment` (optional): the text added in the sharing card, if any
- `title` (optional): the text specified in the title field of the sharing card, if any. Defaults to the title of the page being shared

Additional parameters, e.g. a shared secret, can be configured in the app. They will be sent with each POST request.
