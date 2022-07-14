# Building

Set up the supported versions of npm/node/etc.:

    nvm use

## Linux, Windows

    npm run build

## MacOS

If you don't care about signing (i.e. you are not going to distribute) then you should be able to
simply `npm run build`.

When you want to distribute the app, however, you need to do a bunch of crap to satisfy Apple's
arbitrary security theatre Rube Goldberg machine that purports to keep users safe but in reality is
designed to further Apple lock-in control of the Apple ecosystem.

1.  You have to pay Apple money (every year) to get a developer account.
2.  You need a `Developer ID Application` certificate, created and signed from the Apple, and loaded
    into your system keychain. `security find-identity -v` should show it.
3.  You need to create an [App-specific password](https://support.apple.com/en-al/HT204397) for the
    Apple developer account under which you are notarizing.
4.  In the project root, create a `.env` file with contents:

        SIGNING_APPLE_ID=your-developer-id@example.com
        SIGNING_APP_PASSWORD=app-specific-password

    This password can be plaintext if absolutely needed (e.g. in a CI job) but should be a [keychain
    reference](https://github.com/electron/electron-notarize#safety-when-using-appleidpassword) such
    as `@keychain:some-token` for better security where feasible.

    - If you have multiple ids and need to use a particular signing team ID you can add:

      SIGNING_TEAM_ID=TEAMIDXYZ1

5.  If building from a remote connection (e.g. ssh'd into a mac) then unlock the keychain for that
    session by running `security unlock`.

With all of that set up, your `npm run build` should produce a signed and notarized installer.
Hopefully. Maybe. Sometimes Apple's servers are broken and you might have to try again. But don't
worry, Apple's incompetence around signing makes everything more secure because... reasons.
