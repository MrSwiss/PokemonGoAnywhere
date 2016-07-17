# PokemonGoAnywhere

PokemonGoAnywhere for jailed devices, tap to walk around map in Pokemon Go.

## Warning: Improper Use of this Tweak Will Get You Banned!
As reported on [reddit](https://www.reddit.com/r/pokemongo/comments/4ry7my/psa_spoofing_gps_locations_will_get_you_banned/), spoofing your GPS coordinates in game could get you banned. 

## System Requirements

- Xcode installed (Obviously you need a Mac, a free Apple Developer Account to create provisioning profiles)
- Any iPhone/iPod device (not compatible with iPad)

## Main Components (included)
- CydiaSubstrate (32/64bit)
- [optool](https://github.com/alexzielenski/optool)
- patchapp.sh
- PokemonGoAnywhere.dylib (thanks to William Cobb)
- Pokemon Go.ipa v1.0.2 (not included, version number stated as time of writing this guide)
- [iOS App Signer](https://dantheman827.github.io/ios-app-signer/) or [IMSign](https://github.com/iMokhles/IMSign/releases/tag/v1.3)

## Installation Instructions

#### [Video guide by EverythingApplePro](https://www.youtube.com/watch?v=hjcUbyTvslA)

### **STEP 1**: Download PokemonGo.ipa first, it must be decrypted a.k.a. "cracked". You can find this on [iphonecake](https://www.iphonecake.com/)

### **STEP 2**: Unzip PokemonGoAnywhere-master (I recommend you place the unzipped folder onto the desktop)

### **STEP 3**: Place your copy of PokemonGo.ipa into your previously **unzipped** folder. 
>Rename the .IPA to PokemonGO.ipa if you wish to follow the tutorial directly

### **STEP 4**: Open up your terminal and type(you need an elevated account for the following steps):

```bash
cd path/to/your/unzipped/file-master
```

You should now be in the folders directory. Next, you must elevate optool and patchapp.sh

```
chmod +x patchapp.sh optool 
```

### **STEP 5**: Create your provisioning profile, and [locate it in Finder](https://imgur.com/a/sQHl5)

### **STEP 6**: Type the following into the Terminal, **where you should still be in the unzipped file location**.

```
./patchapp.sh patch path/to/PokemonGo.ipa path/to/your/mobile/provisioning/profile
```
You can just drag your previously located provisioning profile from the Finder into the Terminal.

**HIT ENTER**

You should see the following:

```
[+] Unpacking the .ipa file (/Users/xxxx/Desktop/JailedPokemonGoanyWhere/PokemonGO.ipa)...
[+] Copying .dylib dependences into ".patchapp.cache/Payload/pokemongo.app"
[+] Codesigning .dylib dependencies with certificate "iPhone Developer: xxxx@xxxx.com (XXXXXXXXXX)"
     .patchapp.cache/Payload/pokemongo.app/PokemonGoAnywhere.dylib
     .patchapp.cache/Payload/pokemongo.app/CydiaSubstrate
     PokemonGoAnywhere.dylib
[+] Patching ".patchapp.cache/Payload/pokemongo.app/pokemongo" to load "PokemonGoAnywhere.dylib"
[+] Generating entitlements.xml for distribution ID 
[+] Codesigning the patched .app bundle with certificate "iPhone Developer: xxxx@xxxx.com (XXXXXXXXXX)"
-n      
pokemongo.app: replacing existing signature
[+] Repacking the .ipa
[+] Wrote "PokemonGO-patched.ipa"
[+] Great success!
```

### **STEP 6**: You should have the "PokemonGO-patched.ipa" located in your unzipped file, sideload that .ipa with Xcode.

### **STEP 6.1**: Only if you are facing the following issue while sideloading:
<img width="500" alt="error sideloading" src="https://i.imgur.com/qOfNU4t.png">

Resign the "PokemonGo-patched.ipa" again using [iOS App Signer](https://dantheman827.github.io/ios-app-signer/), if iOS App Signer fails, try [IMSign](https://github.com/iMokhles/IMSign/releases/tag/v1.3).

### KNOWN ERRORS & POSSIBLE FIXES

 Error relating to entitlements.xml seems to be an issue for those with Xcode 8 Beta, solution by /u/arnelmercado
>All you have to do is go to your applications folder and rename "Xcode-beta" or whatever your Xcode application is named to just "Xcode"

Error relating to Xcode's "application-identifier entitlement" error
>If resigning the final IPA with iOS App Signer failed for you, try again using IMSign and resign the "PokemonGo-patched.ipa" again.

Error relating to:
```
...PokemonGoAnywhere.dylib Codesign failed. Have you ran 'make' yet?" 
```
>Delete your developer certificates from Keychain.app and try again..

### Media

<img width="340" alt="error sideloading" src="http://tools4hack.santalab.me/media/uploads/2016/07/jbapp-pokemongoanywhere-04.jpg"> <img width="340" alt="error sideloading" src="http://tools4hack.santalab.me/media/uploads/2016/07/jbapp-pokemongoanywhere-03.jpg"> 

[Me running PokemonGoAnywhere](https://www.youtube.com/watch?v=E5H52fo5980) on iOS 9.3.2, iPhone 6S.

[Video guide by EverythingApplePro](https://www.youtube.com/watch?v=hjcUbyTvslA)

