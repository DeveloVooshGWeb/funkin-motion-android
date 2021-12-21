# GWebDev Funkin Motion Mobile
YES! \
So about motion mobile \
I managed to manipulate tcp sockets and do some messing around \
To send my mobile phone's accelerometer signals onto my computer \
And manipulate it in game to make \
IDK mobile motion to fnf \
And i had a stroke in ballistic i would say LOL \
 \
**NOTE THAT THIS IS ONLY FOR ANDROID RIGHT NOW** \
 \
But yeee it might be a little hard to follow compiling \
To compile for windows just follow the fucking instructions in the main funkin repository over at https://github.com/ninjamuffin99/Funkin \
To compile for android you need to download these 3 things
  - jdk - https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html

  - android studio - https://developer.android.com/studio

  - ndk - https://developer.android.com/ndk/downloads/older_releases?hl=fi \
Yes i know its shit \
First download the java jdk idk how you login and shit then set it up \
Then you need to download android studio and go to its settings -> appearance & behaviour -> system settings -> android sdk -> sdk tools \
Then check goddamn `Android SDK Build-Tools` and `Android SDK Platform-Tools` \
![andrstdsettings](https://user-images.githubusercontent.com/63938719/123502688-d73a1d00-d680-11eb-893a-901f96c3450f.png) \
After that download ndk and extract it (the main folder contains ndk-build or something so basically you copy the path of the folder for example D:\Users\PC\Downloads\android-ndk-r20b) \
And then you go to your terminal, command prompt OR WHATEVER CRAP and then you type in `lime setup android` (i mean if your mac ofc or linux or something and that command is not available then type `haxelib run lime setup android`) \
Then you need to put the directories of those 3 things you downloaded \
For example \
![limesetup](https://user-images.githubusercontent.com/63938719/123502707-fafd6300-d680-11eb-9ea0-9411de181c53.png) \
So you need to put the AndroidStd folder, the folder where the java jdk is installed in, and the folder of the android ndk extracted \
Everything should be precise on the paths \
Then you could do `lime test android` (again the lime command might not work on mac or linux so if thats the case then do `haxelib run lime [your command]`) \
And thats how you setup this stupid project LOL
# How To Setup The PC Version (AKA How To Fucking Hook This Piece Of Shit)
I explained how to setup the android controller so now its time i explain how to hook it onto fnf mods or some fucking shit \
So first of course you need coding experience (if not then just fucking download the files in the releases https://github.com/GrowtopiaFli/funkin-motion-android/releases) \
So your suppose to enable unknown sources in the settings of your android phone which you could research on youtube very quickly https://www.youtube.com \
You know the good part is you dont really need to install more libraries as this only uses the Sys Socket class which is tcp of course \
Tho we cannot set this up for html5 im afraid so sorry LOL \
Keep in mind that this uses a `TCP Socket` and for the web version you could only make a `WEBSOCKET` \
But i mean you could technically code a websocket library in the mobile controller but idk how that will work out since i tried to use one library and it broke
# MOBILE SUPPORT
**THERE IS NO IOS SUPPORT AT THE MOMENT SO SORRY IOS USERS**
