// This is the Debian specific preferences file for Iceweasel
// You can make any change in here, it is the purpose of this file.
// You can, with this file and all files present in the
// /etc/iceweasel/pref directory, override any preference that is
// present in /usr/lib/iceweasel/defaults/preferences directory.
// While your changes will be kept on upgrade if you modify files in
// /etc/iceweasel/pref, please note that they won't be kept if you
// do make your changes in /usr/lib/iceweasel/defaults/preferences.
//
// Note that lockPref is allowed in these preferences files if you
// don't want users to be able to override some preferences.

pref("extensions.update.enabled", true);

// Use LANG environment variable to choose locale
pref("intl.locale.matchOS", true);

// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);

//MX-14.1 preferences
pref("browser.startup.homepage","data:text/plain,browser.startup.homepage=http://mepiscommunity.org/mx14"); 
pref("browser.search.defaultenginename", "data:text/plain,browser.search.defaultenginename=Startpage HTTPS");
pref("browser.search.selectedEngine","data:text/plain,browser.search.selectedEngine=Startpage HTTPS");
