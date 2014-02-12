RGDataBrowser
=============

A configurable iOS template for browsing remote data sets

This project can be used as a starting point for simple apps that show structured data sets. In this example, it reads data from a Google docs spreadsheet (view it [here](https://docs.google.com/spreadsheet/ccc?key=0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE&usp=sharing) by parsing a [JSON representation of that document](http://spreadsheets.google.com/feeds/list/0Apmsn6hlyPHudHUxSHJ1YzhPVjV4VEJTTkl6aGhnclE/od6/public/values?alt=json). The data is stored in Core Data. The following components are used:

* MagicalRecord - makes Core Data easier (especially importing)
* AFNetworking - makes everything around networking calls easier
* CocoaLumberjack - logging
* Kiwi and KIF for testing (pending)
* ideas from http://www.objc.io/issue-1/lighter-view-controllers.html 

For the sample project, I've compiled an (incomplete and potentially error-prone) spreadsheet of countries and cities. There are links to show national flags and wikipedia entries.

Steps if you want to try it out:
1) git clone https://github.com/roland9/RGDataBrowser.git
2) cd RGDataBrowser; pod install   (you need cocoapods)
3) open RGDataBrowser.xcworkspace/

![Screenshot](http://bit.ly/1fgKR1S)
