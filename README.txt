Ruby-Gnome Password Manager

A Ruby-Gnome password manager.
Uses crypt-tea's Tiny Encryption Algorithm to encrypt the datafile.
Features random password generator and clipboard use.


To add an account, enter the new account name in the "Account:" entry/combo box.
For the account, write the associated url, a note about the accout, and the username
in the appropriate entry boxes.

To set a new password, either enter the password in the "New:" entry box, or
generate it by pressing "Random", "Alpha-Numeric", "Numeric", "Letters", or
"All-Caps".  One can set the password length generated with the spin-box.
To make the password generated visible, press the "Visible" button.
The "Current" button copies the current password to the primary clipboard.
The "Previous" button copies the previous password to the primary clipboard.

To delete an account, select the account in the entry/combo box, and
the press the "Delete Account" button.

Once one has edited the account, clicking the "Update" button finalizes the record.
Note, however, that the change is not yet permanent and saved on disk.
Once one is done with all updates, one then needs to press "Save".
"Cancel" or closing the window without "Save" will ignore all of the sessions updates.

The "Change Data File Password" button will allow one the change
the master password.

Right click most anywhere on the app's window for the main menu.
"Close" will dock the app and has the same effect as "Cancel".

Left click on the docked icon to bring back the editor window.

Right click on the docked icon to select one of the accounts to load
the password and username to the clipboard.
The password is copied the the primary clipboard and will paste on
middle mouse button click.
Right click on an entry box to paste the username (via the clipboard's menu).


For full documentation and comments, see

	http://ruby-gnome-apps.blogspot.com/search/label/Passwords

-Carlos
