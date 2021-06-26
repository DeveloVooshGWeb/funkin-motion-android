# Funkin Motion Android
YES! \
So about motion android \
I managed to manipulate tcp sockets and do some messing around \
To send my android phone's accelerometer signals onto my computer \
And manipulate it in game to make \
IDK android motion to fnf \
And i had a stroke in ballistic i would say LOL \
But yeee it might be a little hard to follow compiling \
To compile for windows just follow the fucking instructions in the main funkin repository over at https://github.com/ninjamuffin99/Funkin \
To compile for android you need to download these 3 things \
  - jdk - https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html

  - android studio - https://developer.android.com/studio

  - ndk - https://developer.android.com/ndk/downloads/older_releases?hl=fi
Yes i know its shit \
First download the java jdk idk how you login and shit then set it up \
Then you need to download android studio and go to its settings -> appearance & behaviour -> system settings -> android sdk -> sdk tools \
Then check goddamn `Android SDK Build-Tools` and `Android SDK Platform-Tools` \
![andrstdsettings](https://user-images.githubusercontent.com/63938719/123502688-d73a1d00-d680-11eb-893a-901f96c3450f.png)
After that download ndk and extract it (the main folder contains ndk-build or something so basically you copy the path of the folder for example D:\Users\PC\Downloads\android-ndk-r20b) \
And then you go to your terminal, command prompt OR WHATEVER CRAP and then you type in `lime setup android` (i mean if your mac ofc or linux or something and that command is not available then type `haxelib run lime setup android`) \
Then you need to put the directories of those 3 things you downloaded \
For example \
![limesetup](https://user-images.githubusercontent.com/63938719/123502707-fafd6300-d680-11eb-9ea0-9411de181c53.png)
So you need to put the AndroidStd folder, the folder where the java jdk is installed in, and the folder of the android ndk extracted \
Everything should be precise on the paths \
Then you could do `lime test android` (again the lime command might not work on mac or linux so if thats the case then do `haxelib run lime [your command]`) \
And thats how you setup this stupid project LOL
