# BadgerApp
Source code for app side of badger.

# What needs fixing
Badger 1.2.2 brings *major* optimizations / bugfixes regarding BadgerApp. BadgerApp, beforehand, was a bloated mess. It took up *way* too much storage (6.4MB in 1.2.1-1!) and was pretty unoptimized. The first biggest and needed change it brings is doing gradients via CAGradientLayer rather than storing them in the Assets.car, as well as removing the 1024x1024 app image since, well, we're not adding this to the app store. This brings down the Assets.car from 5.1MB down to just 993KB. This is fine and deals with the main problem, but I still however felt the binary was too large (1.1MB, or 1,134,960 bytes). I wanted to narrow it down below 1MB. I applied -Oz compiler optimizations (I believe I was using -Os or -Ofast before) but it still was too much. I then started going through all the code, and not only helped size but in the process fixed a lot of bugs and just made the source much more easy to manage. I was attempting a *lot* and was doing a ton of work, and while it was helping, the binary size was still 1,035,664 bytes, still just over 1MB. Then, I was talking about some size optimizations I was making, and pythonplayer told me to add -flto compiler flag; I'm going to be honest, I did not know of it beforehand and have no idea what this flag does, but this single flag finally got me down to 935,808 bytes - under 1MB!

And then somehow I got it down to 287KB. I'm going to be honest, I have *no* idea what happened, I literally changed nothing, I just rebuilt BadgerApp one day and it somehow magically jumped from the binary taking 935KB to 287KB. No idea what's happening there, but hey, I'll take it! (Update: After some extra code base optimizations it is now about 265KB).

With that being said, there are still some issues with BadgerApp in the current state. The most noticable is the handling of the UINavigationBar. When in preferences, you may notice there is a navigation bar. When you go to a place that has a gradient, the navigation bar background should be invisible. This brings up probably the most infamous bug with BadgerApp that I've had hell with from the beginning: when transitioning from a no-gradient page to a gradient page, there are two ways to handle the navigation bar that I know of, each with poor results. One - make nav bar background invisible while moving the page. This is bad since on the transition from the no-gradient view controller to the gradient view controller, you can very obviously see that the navbar bg is gone in the no-gradient vc too while transitioning. Two - make nav bar bg invisible once the transition finishes. This sucks since you can see on the gradient view controller during the transition having the navigation bar background. I currently am not knowledgable regarding vc hierarchy to see an easy fix for this. Due to this, in every Badger version up to this point, I just mitigate this via adding a white cover where the view controller normally is in hopes of making this not visible, but this is very, very buggy and often results in doing the exact opposite of it's purpose by causing very noticable visual bugs. I have rewritten this behavior in BadgerApp 1.2.2 - to my knowledge this should be the most stable implementation of `BadgerTopNotchCover` to date, but it's still not perfect, and it would be best to fix the underlying bug at hand here rather than just mitigating it. But, I have no idea how, and still have no idea how to easily handle this even with the full year BadgerApp has been in development now. If you have any idea of potential fixes regarding BadgerTopNotchCover, or, even better, a better way of handling the nav bar bg color during this transition that would defeat the need of BadgerTopNotchCover in the first place, *PLEASE* let me know because this has me stumbled.

Another small-but-impactful change I'm thinking of making is making the app names you currently have preferences for appear above the rest in app selection. This shouldn't be too hard to implement and hopefully improve the "UI feel" by a ton.

I also plan to rewrite this in a way to be storyboard-less later on.

# Testing
If you need to test this in XCode sim, change `preferencesDirectory` in `BadgerPrefHandler.m` to point to whatever directory you want to store preferences in. Be aware though that currently, `ViewController.m` still will check for a file in the hardcoded path and this will not update custom images / custom fonts, I should change that behavior soon :P. There are no unit tests - at all - which TBH I probably should do, lol. (Well, ok, I did have some tests for the preference handler, but I stored them seperately main source directory and I can't really find where I put it, though even if I did they aren't really ready for public use anyway). However, for the most part, if you try to set a preference, then exit, and go back and it's still there, preferences likely work fine.

# Compiling
Change the team identifier to yours, and (for the most part) just compile. Be aware though to remove `TestBadgerPrefs.plist` afterwards (you don't *have* to, but it's not needed). Make sure to also `ldid -Sent.xml /path/to/BadgerApp.app/BadgerApp`, you can find the entitlements plist here or the tweak-side source whenever I eventually get around to OS'ing it. You also should `sudo chown 0:0 ./layout/Applications/BadgerApp.app/BadgerApp`, and (maybe?) `sudo chmod 6755 ./layout/Applications/BadgerApp.app/BadgerApp`. From then on, your compile BadgerApp.app should be usable.
