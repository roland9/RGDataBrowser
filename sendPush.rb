require 'houston'

# Environment variables are automatically read, or can be overridden by any specified options. You can also
# conveniently use `Houston::Client.development` or `Houston::Client.production`.

# APN = Houston::Client.development
APN = Houston::Client.production

# APN.certificate = File.read("/Users/roland/Desktop/RGDataBrowserCertificatesDEV.pem")
APN.certificate = File.read("/Users/roland/Desktop/RGDataBrowserCertificatesPROD.pem")

# An example of the token sent back when a device registers for notifications
# token = "<c8f78ddd a0a029ba 61a78077 d99bc247 1baec009 8a2cbb14 874e225c 0867638a>"  # RGDataBrowser, iPhone 5
# token = "<bcaf71c7 fa44d429 d6508b7a 678040c1 3775e538 d4467d7d 458689e5 88968ca2>" # RGDataBrowser, iPod touch 
# token = "<152ef434 510254f2 b07ec11d c31f0553 bf9b6eab c6788a04 5078bd07 6f7c23fb>" # ProjectMap, iPod touch 
token = "<e0c908ae 520d611f afbcd9e4 a4af4e66 35ace3ee ca99428b 21cf87ba d3e1f8dd>"  # RGDataBrowser PROD, iPod touch

# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
notification = Houston::Notification.new(device: token)
notification.alert = "Hello, World!"

# Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
notification.badge = 57
notification.sound = "sosumi.aiff"
notification.category = "INVITE_CATEGORY"
notification.content_available = true
notification.custom_data = {foo: "bar"}

# And... sent! That's all it takes.
APN.push(notification)
