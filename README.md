# Piwigo Next Generation (for Android)

An android application for managing and uploading images to Piwigo servers.

This app is **under development** by the Piwigo android team. The goal is to close the gap with the IOS Piwigo application while keeping in mind the priority of the features like the **upload**, and the ability to **select multiple images** at a time or to **take photos directly from the app** to upload them.

All features are not enabled and will be implemented when needed.
If you face trouble please [create tickets](https://github.com/Piwigo/piwigo-flutter-app/issues/new/choose) in case you detect a bug.


# Installation

You can download the latest version either from Github or from Google Play Store:

## Download from Play Store

On your Android phone:
 1. Go to **Play Store**.
 2. Search for **Piwigo NG** on search-bar.
 3. Find the listing with the name **Piwigo NG (Early Access)** and click **Install**.

Alternatively, you can directly go to the [Play Store page of Piwigo NG app](https://play.google.com/store/apps/details?id=com.piwigo.piwigo_ng).

## Download from Github

### Download the APK

In Github, Go to [piwigo-flutter-app releases](https://github.com/Piwigo/piwigo-flutter-app/releases), choose the version (latest is recommanded) and download the .apk file.

### Install the APK

On your Android phone:
 1. Go to **Settings** > **security** > **install unknown apps**.
 2. Go to **files** and enable **Allow from this source**.
 *Don't forget to disable it when you have finished*
 3. Exit **Settings** and go to **files**.
 4. Go to **Downloads**, select the **.apk** and click **install**.
 6. The app is now installed on your phone.

# Usage

How to use Piwigo NG

## Login
![Piwigo's login screen](https://i.imgur.com/KIX3K2o.png)

 - Enter the piwigo **address** of the server you want to log into :
	 - Switch between **http** and **https** by tapping on them.
*[http is not supported yet](https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android)*
	 - No need to end the URL with a **/**.
 - Enter the **username** and the **password** for the server you want to log into :
	 - Leave those fields **empty** if you just want to visit the server. You will be logged as a **guest**.
 - Tap the **Log in** button :
	 - If the given URL is empty, the Log in button will be disabled.
	 - If the login is not successful, a dialog describing the error will appear. Tap outside the dialog to retry.

![Login Error Dialog](https://i.imgur.com/M1NgMtz.png)

## Logout | Change server

#### From the Albums Home Page
- Go to **Settings**.
	- If you are logged in : Tap **Log out**.
	- If you are a guest : Tap **Log in**.

![Settings Page](https://i.imgur.com/iPOjYRs.png)
## Upload
With Piwigo NG, you can upload images from the phone.
1. **Enter** (or **create**) an album.
2. Tap on the **menu button** at the bottom right corner.
3. Tap the **image button** to select images for upload.

![Menu Button](https://i.imgur.com/TzxBA5c.png)

4. **Select** the images from your phone
	4.1. You can **take a photo directly** from the app by tapping the camera icon.

![Multiselection Page](https://i.imgur.com/Etvq7TE.png)

5. Validate by tapping the **check** button on the top right corner.
6. Review the selected images and tap the **upload** button to confirm or exit ton cancel.
7. The upload will start in **background**, you can continue to use the app or even leave it.
	7.1. Some **notifications** will appear each time an image is fully downloaded.
	7.2. The result will be visible when all the images have been updated.

![Upload Page](https://i.imgur.com/Etvq7TE.png)

# Flutter

This application is made with [Flutter](https://flutter.dev/?gclid=Cj0KCQjwvYSEBhDjARIsAJMn0lj-G1Ly0oznQeMGvyTYBY2TZfxFpkb9WYp4dsyMSwKIUsmTwE-SltIaAsjFEALw_wcB&gclsrc=aw.ds)

A UI toolkit for building beautiful, natively compiled applications for [mobile](https://flutter.dev/docs), [web](https://flutter.dev/web), and [desktop](https://flutter.dev/desktop) from a single codebase.

We are using it for Android only.

# Piwigo API

The connection to the server is made with the Piwigo's API.

## Upload

For the upload, we are using the **uploadAsync** method of the API. This method requires to **chunk** the image with a size given by the server. All chunks are uploaded simultaneously and reorganized by the server.


# Licence

Piwigo is a free software, it can be redistributed it and / or modified under the terms of the GNU General Public License
[see more here](./LICENCE.txt)
