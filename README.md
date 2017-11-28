## SendAsPOST
Share extension for iOS to send photos and links as POST requests

###
The share extension appears on the list when a user taps the Share icon for a photo or a web page. Depending on what's being shared, the extension will send different parameters with the POST request: `caption` and `image` for a photo and `comment`, `title`, `url`, and `quote` for a URL. 

Opening the main application allows you to send extra parameters, e.g. a shared secret for authentication, with every POST request.

### Known issues

When using Reader View on mobile Safari, the selected text doesn't make it through the preprocessing javascript. Need to investigate if this is intentional on Apple's part, or possibly a bug. 

### To Do

- More documentation
- [sendaspost.com](sendaspost.com)
