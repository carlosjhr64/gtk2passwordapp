# Gtk2PasswordApp

* [VERSION 6.3.230117](https://github.com/carlosjhr64/gtk2passwordapp/releases)
* [github](https://github.com/carlosjhr64/gtk2passwordapp)
* [rubygems](https://rubygems.org/gems/gtk2passwordapp)

![gui](test/gui.png)

## Description:

Ruby-Gnome Password Manager.

Uses Blowfish to encrypt the datafile.
Features random password generator, clipboard use, and TOTP.

## Install:
```console
$ gem install gtk2passwordapp
```
## Help:
```console
$ gtk2passwordapp --help
Usage:
  gtk2passwordapp [:gui+]
  gtk2passwordapp :cli [<pattern> [<file>]]
  gtk2passwordapp :info
Gui:
  --minime      	 Real minime
  --notoggle    	 Minime wont toggle decorated and keep above
  --notdecorated	 Dont decorate window
Cli:
  --nogui
Info:
  -v --version   	Show version and exit
  -h --help      	Show help and exit
# Notes #
With the --nogui cli-option,
one can give a pattern to filter by account names.
Default passwords data file is:
  ~/.cache/gtk3app/gtk2passwordapp/dump.yzb
```
## Gui:

Mouse clicks on logo:

+ Button #1: Get the passwords list and select.
+ Button #2: Reset the master password.
+ Button #3: Application menu.

When you select an account,
the username/password will be in clipboard/primary for a few seconds.

View Account page:

* click on password to toggle visibility.
* click on secret to toggle TOTP(secret is password).
* `Current` button will put username/password in clipboard/primary for a few seconds. 
* `Previous` button will put password/previous in clipboard/primary for a few seconds. 

## Configuration:
```console
$ ls ~/.config/gtk3app/gtk2passwordapp/config-?.?.rbon
```
+ Salt:  If your master password length is under 16(LongPwd), it'll append this Salt.
+ TooOld:  I have this set for a year (in seconds).
+ PwdFile:  passwords file... you'll want include this file in your back-ups.

## On password length

As of early 2023,
[Blockchain.com](https://www.blockchain.com/explorer/charts/hash-rate)
charts the total hash rate of the Bitcoin network approaching `300*M*TH/s`.
Interpreting this as the number a passwords it can test per second,
I estimate the number of passwords it could test in two years:
```ruby
# Passwords attempted in two years:
M         = 1_000_000
T         = M*M
YEAR      = 60*60*24*365
PASSWORDS = 2*YEAR*300*M*T
# There are 94 graph characters in ASCII.
# I can estimate the password length needed to cover this number of PASSWORDS:
Math.log(PASSWORDS,94).ceil #=> 15
# Excluding the quotes in graph, it's still:
Math.log(PASSWORDS,91).ceil #=> 15
```
So that's how come to a default password length of 15.

## Trouble shooting on upgrades

Edit your configuration file's `:Salt` value
to what it was set in your previous configuration.
Also, the `:LongPwd` value changed from 14 to 16,
so if your long password length was 14 or 15,
you'll have to enter that as it's now considered short
and set `:Salt` to "".

## LICENSE:

(The MIT License)

Copyright (c) 2023 CarlosJHR64

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
