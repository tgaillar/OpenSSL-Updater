<!---
  # Retrieve from Github Wiki
  # =========================
  curl -s https://raw.githubusercontent.com/wiki/tgaillar/OpenSSL-Updater/Home.md
-->
# Welcome to the OpenSSL-Updater / webOS wiki!
![](https://github.com/tgaillar/OpenSSL-Updater/blob/master/icon_splash.png)

## Table of Contents
* [Summary](#summary)
* [Alpha Test](#alpha-test)
* [Installation / Removal](#installation--removal)
* [Context](#context)
* [Solution](#solution)
* [Palm/HP Unpublished OpenSSL Patches](#palmhp-unpublished-openssl-patches)
* [OpenSSL Patches](#openssl-patches)
* [Testing](#testing)
* [Thanks](#thanks)


## Summary
Lately, more and more webOS users have been experiencing the "error: requested encryption not supported by server" in the mail application, aka "the yellow triangle of death".

Major servers on the web are moving away from SHA-1 to SHA-256 certificates. However, legacy webOS devices cannot natively process SHA-256 certificates, forcing users to trust server-presented certificates in their devices on a regular basis to keep their mail application working... **No-one can survive that, not for long!**

[OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater) is a system-wide solution that brings SHA-256 certificates digest capability from the latest OpenSSL 0.9.8 release to your webOS smartphone/tablet (this is not to be confused with the [optware version](https://github.com/webos-internals/build/tree/master/optware/openssl) version that gets installed in ```/opt```).

*Current version is meant/expected to work on webOS 2.x/3.x devices. Testing was not performed on webOS 1.4.x and is not expected to work at all (for now, this may change in the future)*.

## Alpha Test
[OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater) is currently in **alpha test**.

At the moment, to get [OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater), you have to enable the **alpha feeds** in [Preware](http://www.webos-internals.org/wiki/Application:Preware). **To do so, please follow [these instructions](http://www.webos-internals.org/wiki/Testing_Feeds#Enabling_the_Alpha_Testing_Feeds)**.

Ideally, testing shall be conducted as follows (one step at a time, only a single parameter change per step):
* without the app installed, remove installed certs until you get the issue (yellow triangle, "error: requested encryption not supported by server", ...)
* install the app and verify the issue does not happen anymore
* remove the app, the issue shall be back


Alpha testers, please report directly in [GitHub](https://github.com/tgaillar/OpenSSL-Updater/issues) (can you also identify in the [webOS Nation thread](http://forums.webosnation.com/webos-internals/330666-openssl-updater-fixing-certificate-issues.html) or PM me, we're not so many left in the field and your feedback is needed so we can safely move out of alpha/beta...)

Any other information/request you would like to share/ask, please report in [the dedicated thread at webOS Nation](http://forums.webosnation.com/webos-internals/330666-openssl-updater-fixing-certificate-issues.html).


## Installation / Removal
Just install [OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater) from [Preware](http://www.webos-internals.org/wiki/Application:Preware).

Simply uninstall the application to return your device to its original, unpatched state (either directly from the device, through [Preware](http://www.webos-internals.org/wiki/Application:Preware) or via the "```palm-install -r org.webosinternals.openssl-updater```" command).

**A system reboot is required after installation/removal, as running programs will see their OpenSSL dynamic libraries change (and most certainly crash). This is automagically performed by the end of the installation/removal process.**


## Context

Lately, more and more webOS users have been experiencing the "_google error: requested encryption not supported by server_" yellow triangle in the mail application (see [webOS Nation thread](http://forums.webosnation.com/hp-touchpad/329860-google-error-requested-encryption-not-supported-server.html)).

Google is now in the process of "[Gradually sunsetting SHA-1](https://googleonlinesecurity.blogspot.fr/2014/09/gradually-sunsetting-sha-1.html)" (see also "[Why Google is Hurrying the Web to Kill SHA-1](https://konklone.com/post/why-google-is-hurrying-the-web-to-kill-sha-1)").

As it was properly hinted in a webOS Nation forum thread (user *Preemptive* in "[SHA256, Root Certificates, OpenSSL: Future Security](http://forums.webosnation.com/webos-tips-info-resources/329502-sha256-root-certificates-openssl-future-security.html#post3435401)"):
> It is not clear if the legacy version of OpenSSL (0.9.8j / k) will automatically process SHA256. It is apparently capable, but needs to be activated. It's not clear if webOS does this.
> Update (14th August 2015): NIN_ru has done some research that indicates there was a bug in OSSL. It was patched in a later, incompatible version. The conclusion seems to be that webOS is capable of matching SHA256 certificates, but not installing them automatically.
> 
> [https://marc.info/?l=openssl-users&m=135355590501495](https://marc.info/?l=openssl-users&m=135355590501495)

And indeed:
> List:       openssl-users
> Subject:    Re: Does OpenSSL 0.9.7 support SHA256 Digest Algorithm
> From:       Gayathri Manoj <gayathri.annur () gmail ! com>
> Date:       2012-11-22 3:54:45
> Message-ID: CAKqy4TN25Zw0D-tTq4xsGw_Ed=6um=ndmwTurR5JuFVsh2f-Xg () mail ! gmail ! com
> [Download message RAW]
> 
> Hi Aaron,

> If your openssl version supports sha256 and its version is less than
> 0.9.8l, then you  should add OpenSSL_add_all_algorithms() in your code  to
> enable the same. Otherwise it  will throw errors while doing any
> digest operation with sha256.
> 
> By default sha256 is enabled  on Openssl-0.9.8l version onwards.
> 
> 
> Thanks,
> Gayathri

Palm/HP webOS devices were delivered with what is now pretty much [obsolete versions of OpenSSL 0.9.8](http://openssl.org/source/old/0.9.x/):
* webOS 2.x/3.x: [OpenSSL 0.9.8k 25 Mar 2009](http://openssl.org/news/changelog.html#x31)
* webOS 1.4.x: [OpenSSL 0.9.8j 07 Jan 2009](http://openssl.org/news/changelog.html#x32)

**The short story is legacy webOS devices cannot natively process SHA-256 certificates, forcing users to trust server-presented certificates in their devices on a regular basis to keep their mail application working... No one can survive that, not for long!!**


## Solution

Basically, recompile the latest OpenSSL 0.9.8 release (armv7, armv6 & i686) and replace the original binaries with the new ones (then reboot!). There were 3 identified files:
* ```/usr/bin/openssl```
* ```/usr/lib/libcrypto.so.0.9.8```
* ```/usr/lib/libssl.so.0.9.8```

The [OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater) application packages those 3 files and installs them as part of the embedded installation script (and removes them as part of the embedded removal script)

**As tested, bringing the latest OpenSSL 0.9.8 release to webOS 2.x/3.x devices immediately restored full GMAIL functionality (without the need for trusting the server-presented certificates which had first been removed).**

However, functionality for Microsoft Echange/EAS accounts (Exchange ActiveSync -- Microsoft Exchange logo)  was lost during this process, forcing a deeper analysis of Palm/HP-delivered files to understand the issue.


## Palm/HP Unpublished OpenSSL Patches

Long story short (*to be elaborated*), Palm/HP applied several patches to OpenSSL 0.9.8 **but never published them on their [HP webos open source compliance / Open Source Packages](http://wayback.archive.org/web/20150208070200/http://www.openwebosproject.org/opensource/packages.html)**.

So far, those patches seem to cover the following areas (incomplete list until fully analyzed):
* In-Context (!) certificate digest capability, needed for the Microsoft Exchange / [Exchange ActiveSync](https://en.wikipedia.org/wiki/Exchange_ActiveSync) profile in the Accounts application
* [EAP-FAST](https://en.wikipedia.org/wiki/Extensible_Authentication_Protocol#EAP-FAST) (Flexible Authentication via Secure Tunneling), possibly needed for the Cisco AnyConnect option in the VPN application
* ... (*to be continued*)


## OpenSSL Patches

Applied reverse-engineered patch(es):
* In-Context (!) certificate digest capability [for OpenSSL 0.9.8k](https://github.com/tgaillar/OpenSSL-Updater/blob/master/src/patch/openssl-0.9.8k-palm.patch) and [for OpenSSL 0.9.8zg](https://github.com/tgaillar/OpenSSL-Updater/blob/master/src/patch/openssl-0.9.8zg-palm.patch)

Non-applied patch(es):
* EAP-FAST [for OpenSSL 0.9.8k](https://github.com/tgaillar/OpenSSL-Updater/blob/master/src/patch/openssl-0.9.8k-tlsExtension.patch)


## Testing
[OpenSSL-Updater / webOS](https://github.com/tgaillar/OpenSSL-Updater) was successfully tested on the following devices:
* **webOS 2.2.4 Emulator Image (Pre2 and Pre3)** (started its life fresh from the SDK-2222.vmdk.zip emulator-images)
* **webOS 2.2.4 Palm Pre2** (started its life quite some time ago after a visit to the webOS Doctor / webosdoctorp224pre2wr.jar), a day-to-day phone up to now
* **webOS 3.0.5 WiFi Touchpad** (most probably started its life 3.0.2, then went OTA 3.0.4 and 3.0.5), a day-to-day tablet up to now


## Thanks

Many thanks to [Rod Whitby](https://github.com/rwhitby) & [the webOS Internals team](https://github.com/webos-internals) for [building the tools and the distribution infrastructure](https://github.com/webos-internals/build), this would not have been possible without their great work. Special thanks to Rod for his quick and effective support in [accepting the app in the build system and reviving the WOI feeds](https://github.com/webos-internals/build/pull/40). 
