//
pref("app.update.channel", "default");

// Use LANG environment variable to choose locale
pref("intl.locale.matchOS", true);

// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);

// Prevent EULA dialog to popup on first run
pref("browser.EULA.override", true);

// Activate the backspace key for browsing back
pref("browser.backspace_action", 0);

// Disable ipv6
pref("network.dns.disableIPv6", true);

// Ignore Mozilla release notes startup pages
pref("browser.startup.homepage_override.mstone", "ignore");

// Save tabs before exiting
user_pref("browser.showQuitWarning", true);

