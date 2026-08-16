# KubarOK iOS app target

Open `KubarOK.xcodeproj` in Xcode on macOS. The `KubarOK` target uses iOS 16.0,
Swift 6, SwiftUI lifecycle, and the local package at `../../Packages/KubarOKCore`.

The placeholder bundle identifier is `id.go.kutaibarat.kubarok`. Confirm the
official identifier and select an Apple Developer team before device, archive,
or App Store builds. Automatic signing is enabled, but no team, certificate, or
provisioning profile is committed.

`Assets.xcassets` has an empty AppIcon placeholder and a temporary AccentColor.
Replace the icon with approved production artwork before distribution.

The project has no ATS exceptions and requests no privacy permissions. The
existing API uses HTTPS normally.
