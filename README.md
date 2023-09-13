# BadgerApp
Source code for app side of badger.

# 1.2.2 Fixes
Badger 1.2.2 brings *major* optimizations / bugfixes regarding BadgerApp. BadgerApp, beforehand, was a bloated mess. It took up *way* too much storage (6.4MB in 1.2.1-1!) and was pretty unoptimized. The first biggest and needed change it brings is doing gradients via CAGradientLayer rather than storing them in the Assets.car, as well as removing the 1024x1024 app image since, well, we're not adding this to the app store. This brings down the Assets.car from 5.1MB down to just 993KB. This is fine and deals with the main problem, but I still however felt the binary was too large (1.1MB, or 1,134,960 bytes).

I wanted to narrow it down below 1MB. I applied -Oz compiler optimizations (I believe I was using -Os or -Ofast before) but it still was too much. I then started going through all the code, and not only helped size but in the process fixed a lot of bugs and just made the source much more easy to manage. I was attempting a *lot* and was doing a ton of work, and while it was helping, the binary size was still 1,035,664 bytes, still just over 1MB. Then, I was talking about some size optimizations I was making, and pythonplayer told me to add -flto compiler flag; I'm going to be honest, I did not know of it beforehand (it enables link-time optimization), but this finally got me down to 935,808 bytes - under 1MB!

And then somehow I got it down to 287KB. I'm going to be honest, I have *no* idea what happened, I literally changed nothing, I just rebuilt BadgerApp one day and it somehow magically jumped from the binary taking 935KB to 287KB. No idea what's happening there, but hey, I'll take it!

After that, I started looking at all the code again, trying to optimize it all, again to attempt to result in a smaller binary size. After a lot of hard work, I eventually got it down from 287KB to 255KB. While this doesn't seem like much, only about 30KB, I'd still consider it a success since I wasn't doing this *just* for a smaller binary size, but hoped in turn that looking at all the code and optimizing it once again would also lead me to improve the formatting/readability as well as fix bugs throughout the entire codebase, which it did. For example, I noticed that searching has been bugged in the ViewController due to using the wrong variable to get a table cell, instead of getting filtered cells I got unfiltered cells. No idea how I didn't notice this bug or no one has reported it, I have looked and found this bug is present in every release of Badger including 1.0, but at least it's fixed now. Another example of a bad bug is that in the CountConfigManager, I had a safety check that was supposed to prevent bad behavior if anything went wrong, but turns out this backfired and would cause weird behavior when attempting to remove some settings when your language is not set to English, no idea how long that's been there (I hope this never made it to release) but it's patched now too :P.

We're already at a good size now, about 1.5MB for the full app. But what if we were to go further beyond?

After this I wanted to look at optimizing the Assets.car once again. I found ImageOptim, a lossless compression tool, however I noticed that even though it did make the assets much smaller, when I built the project the resulting size was still the same size. Applying XCode's asset catalog optimization brought us down to 974KB. I was now thinking, maybe something's wrong with how XCode is building the Assets.car. I decided to separate all of the assets from the assets.car (and turned off XCode's PNG compression since it seemed to add 40KB to the assets; this is because it optimizes the images for launch speed, however ironically this actually results in *worse launch speed* than optimizing for size, https://imageoptim.com/xcode.html https://imageoptim.com/tweetbot.html). This brought BadgerApp's binary down about 270KB in size, a massive help. The entire BadgerApp.app 1.2.2 size was a little less than 1.1MB and was smaller than the BadgerApp 1.2.1-1 binary alone.

I was mentioning these size improvements, and alexia mentioned using oxipng, another lossless compression tool. This turned out to be better than ImageOptim, and resulted in a 8KB reduction, admittedly not much but with how little work it was I'd gladly take those gains. I now shifted back to my Assets.car where now only my app icons were, using oxipng to decompress them may have helped a little but not by much. I looked at it and noticed that it stores some images, for example the 120x120 image, twice in some scenarios ex iPhone 3x 40x40 and iPhone 2x 60x60. Apparently I've heard Xcode 14 has a Single Asset Mode that will fix this, but I'm still on Xcode 13, and attempting to modify the Contents.json of my Assets.xcassets to point to the same images for some sizes didn't seem to work :P. However, I decided to check my build settings and discovered something pretty funny, I have been leaving on Generate Debug Symbols, even in release builds. Oops. Turning that to NO resulted in the binary going from 254,720 bytes down to 207,600 bytes, and some bugfixes and micro-optimizations shortly after brought us down to 201,216 bytes. Now, in release builds, BadgerApp.app 1.2.2 sould take under 1MB.

But what if we were to go even beyond?

Ok, so, my experience with oxipng made me look into other compressors, where I found Caesium. For the most part I've been using lossless compression to sacrifice no quality. However, if we use Caesium and use lossy compression but turn quality to 100%, (i think- not exactly sure what it all does to the image) it switches the color profile to a different one that takes up less space and has no visible quality loss at all, at least to me, I looked side by side and couldn't notice a single difference visually. Applying this compression which seems to have no visual difference results in Assets.car 367,672->120,088, with the full BadgerApp.app 1,017,505->589,448. In the release build this should result to **507,993** bytes total for the app.

I am *very* happy with these optimizations. You could take the BadgerApp.app 1.2.2 Beta 4, multiply it 9 times and still result in a smaller size than BadgerApp 1.2.1-1's Assets.car alone. The 1.2.2 beta 4 deb is now under 400KB, in comparison to 1.2.1-1's deb size which was 5.4MB. The app's codebase also now is much more readable and optimized, and overall just will be much easier for me to work with in the future.

# What needs fixing

With that being said, there are still some issues with BadgerApp in the current state. The most noticable is the handling of the UINavigationBar. When in preferences, you may notice there is a navigation bar. When you go to a place that has a gradient, the navigation bar background should be invisible. This brings up probably the most infamous bug with BadgerApp that I've had hell with from the beginning: when transitioning from a no-gradient page to a gradient page, there are two ways to handle the navigation bar that I know of, each with poor results. One - make nav bar background invisible while moving the page. This is bad since on the transition from the no-gradient view controller to the gradient view controller, you can very obviously see that the navbar bg is gone in the no-gradient vc too while transitioning. Two - make nav bar bg invisible once the transition finishes. This sucks since you can see on the gradient view controller during the transition having the navigation bar background. I currently am not knowledgable regarding vc hierarchy to see an easy fix for this. Due to this, in every Badger version up to this point, I just mitigate this via adding a white cover where the view controller normally is in hopes of making this not visible, but this is very, very buggy and often results in doing the exact opposite of it's purpose by causing very noticable visual bugs. I have rewritten this behavior in BadgerApp 1.2.2 - to my knowledge this should be the most stable implementation of `BadgerTopNotchCover` to date, but it's still not perfect, and it would be best to fix the underlying bug at hand here rather than just mitigating it. But, I have no idea how, and still have no idea how to easily handle this even with the full year BadgerApp has been in development now. If you have any idea of potential fixes regarding BadgerTopNotchCover, or, even better, a better way of handling the nav bar bg color during this transition that would defeat the need of BadgerTopNotchCover in the first place, *PLEASE* let me know because this has me stumbled.

The codebase structure is significantly more readable and easier to work with, and while I did touch up everything there are still some classes that definitely could use some work, for example BadgeCountMinimumViewController.

Another small-but-impactful change I'm thinking of making is making the app names you currently have preferences for appear above the rest in app selection. This shouldn't be too hard to implement and hopefully improve the "UI feel" by a ton.

I also plan to rewrite this in a way to be storyboard-less later on.

This is so small that it's not even worth fixing but I should say it here anyway: In BadgeColorViewController's matchingLabelColor: method, there is a NSDictionary containing 14 keys for some possible color values. However, some of the keys, we don't need to create two UIColor objects for, ex @"Default (Red)" and @"Red". In Objective-C, TMK there is no easy way to signal for a dictionary value to be the same as te next in the chain. I know what you're thinking: just have a UIColor variable out of the dictionary and have those two keys use the same pointer. However creating this UIColor would be out of the chain and in return very slightly messes up compiler optimizations... (at least that's what I think is going on, but all I know is I tried this already and it didn't work). So, instead, we take advantage of how when the dictionary chain gets to the next object to fill @"Red" with, the x0 register still has the result of the previous objc_msgSend call, so we inline arm64 assembly to force clang to re-use the x0 register. This is better and saves two not needed objc_msgSend calls that perform UIColor creations, however there is also two not needed `mov x0, x0` instructions we theoretically could remove. However, I have no idea how to do this in a way clang will let us, and, to be honest, I'm not really that into finding out how for a 2 instruction loss which shouldn't even take a full nanosecond to perform. If you figure out how in a PR (preferrably for removing the 2 instructions entirely, but finding out another instruction with less latency but will still have clang realize we can re-use x0 would still be an improvement, though it would be difficult making this better, the Cortex-A57 Software Optimization Guide mentions mov having 1 exec latency and 2 execution throughput, so the only possible faster instruction TMK would be one that has 1 exec latency and 1 execution throughput, an example is a nop instruction but I don't know how to replace this with a nop and still have clang recognize that we can re-use x0), it would be nice, but I wouldn't really recommend wasting your time on a 2 instruction loss, lol.

# Contributing
Contributions are welcome (albeit keep in mind until I finish 1.2.2 I'll be pretty active here, so it's recommended that you make a PR after 1.2.2 is released, but if you feel like it or if it's something really important feel free to do it anyway).

FINISH LATER

# Testing
If you need to test this in XCode sim, change `preferencesDirectory` in `BadgerPrefHandler.m` to point to whatever directory you want to store preferences in. Be aware though that currently, `ViewController.m` still will check for a file in the hardcoded path and this will not update custom images / custom fonts, I should change that behavior soon :P. There are no unit tests - at all - which TBH I probably should do, lol. (Well, ok, I did have some tests for the preference handler, but I stored them seperately main source directory and I can't really find where I put it, though even if I did they aren't really ready for public use anyway). However, for the most part, if you try to set a preference, then exit, and go back and it's still there, preferences likely work fine.

# Compiling
Change the team identifier to yours, and (for the most part) just compile. Be aware though to remove `TestBadgerPrefs.plist` afterwards (you don't *have* to, but it's not needed). Make sure to also `ldid -Sent.xml /path/to/BadgerApp.app/BadgerApp`, you can find the entitlements plist here or the tweak-side source whenever I eventually get around to OS'ing it. You also should `sudo chown 0:0 ./layout/Applications/BadgerApp.app/BadgerApp`. From then on, your compile BadgerApp.app should be usable.
