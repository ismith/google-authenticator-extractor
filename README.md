# Google Authenticator Extractor

## Prereqs
You'll need `zbarcam`, `tee`, `protoc`, and `oathtool`.

On Ubuntu, this is:
`apt install -y zbar-tools coreutils protobuf-compiler oathtool`.

On OS X:
`brew install zbar protobuf oath-toolkit`. (I haven't tested this with OS X; you
may also need `coreutils`, in which case you'll need the un-prefixed binaries in
your path when running `script.sh`: `PATH=$(brew
--prefix)/coreutils/libexec/gnubin:$PATH script.sh`.)

## Getting QR Codes from your device
Google Authenticator has in its menu a `Transfer accounts` flow. It puts a QR
code on the screen encoding the accounts you've selected. I was only able to do
3-4 at a time; batches of 8 made the QR code detailed enough that my webcam
couldn't focus on it. You'll probably also want to dim your screen to about 50%.
Reflections on the phone screen may also cause problems; angling the phone some
may help, or you could dim the computer monitor as far as possible.

Run `zbarcam | tee codes`; when `zbarcam` detects a QR code, it will print it to
the terminal, looking something like
`QR-Code:otpauth-migration://offline?data=...`, and also save that string to
`codes`.  Transfer all the accounts you need.

**Store `codes` securely - these are your TOTP secrets.**

## Transforming `codes` into secrets and TOTPs
Run `./script.sh`; it will print a list of json objects like:
```json
{
  "totp": "123456",
  "secret": "<BASE32-ENCODED SECRET>",
  "name": "example.com:emailaddress@example.com",
  "issuer": "The Example Site"
}
```

You can compare the `totp`s you get with what shows in Google Authenticator to
confirm everything transferred correctly.

## Future work
The data `script.sh` prints is enough to generate a QR code - wouldn't be too
hard to set this up to import into another 2FA/TOTP tool.
