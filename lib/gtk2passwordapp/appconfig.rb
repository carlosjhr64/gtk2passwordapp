# Note: you'll see in ~/.gtk2passwordapp-* a file called passphrase.txt.
# Do not edit or delete passphrase, or you'll loose your passwords data.

module Gtk2AppLib
# Only one gtk2passwordapp will be allowed to run.
# Will kill a duplicate proccess...
Lock.lock_mode
module Configuration

  padding = Widgets::WIDGET[:Widgets][:pack_start].last
  go = 50
  label = 75
  entry = 300
  spin = 60
  check = 20

  if HILDON then
    FONT[:NORMAL] = FONT[:LARGE] = Pango::FontDescription.new( 'Arial 18' )
    go = 75
    label = 150
    entry = 500
    spin = 75
    check = 25
    if Gtk2AppLib::Configuration::OSTYPE == 'Internet Tablet OS: maemo Linux based OS2008' then
      # Icon works on N800, but not N800 (Maemo 5)
      MENU[:close]		= '_Close'
    end
  else
    WINDOW_DEFAULT_SIZE[0],WINDOW_DEFAULT_SIZE[1] = 100,100
    MENU[:close]		= '_Close'
  end
  MENU[:help] = '_Help'

  wrap		= {:wrap= => true}
  label_width	= {:width_request= => label, :wrap= => true}
  entry_width	= {:width_request= => entry}
  shorten_a	= {:width_request= => entry - go - 2*padding}
  shorten_b = {:width_request= => entry - spin - check - 4*padding, :visibility= => false}
  go_width	= {:width_request= => go}
  check_width	= {:width_request= => check, :active= => true}
  spin_width	= {:width_request= => spin, :set_range  => [3,30]}
  clicked	= 'clicked'

  PARAMETERS[:Account_Label]		= ['Account:',label_width]
  # nil needs to be set to the accounts list in bin/gtk2passwordapp
  PARAMETERS[:Account_ComboBoxEntry]	= [nil,entry_width,'changed'] # catching changed signal

  PARAMETERS[:Url_Label]	= ['Url:',label_width]
  PARAMETERS[:Url_Entry]	= [shorten_a]
  PARAMETERS[:Url_Button]	= ['Go!',go_width,clicked]

  PARAMETERS[:Note_Label]	= ['Note:',label_width]
  PARAMETERS[:Note_Entry]	= [entry_width]

  PARAMETERS[:Username_Label]	= ['Username:',label_width]
  PARAMETERS[:Username_Entry]	= [entry_width]

  PARAMETERS[:Password_Label]	= ['Password:',label_width]
  PARAMETERS[:Password_Entry]	= [shorten_b]
  PARAMETERS[:Password_CheckButton]	= [check_width,'toggled']
  PARAMETERS[:Password_SpinButton]	= [spin_width]

  PARAMETERS[:Random_Button]	= ['Random',clicked]
  PARAMETERS[:Alpha_Button]	= ['Alpha-Numeric',clicked]
  PARAMETERS[:Numeric_Button]	= ['Numeric',clicked]
  PARAMETERS[:Letters_Button]	= ['Letters',clicked]
  PARAMETERS[:Caps_Button]	= ['All-Caps',clicked]

  PARAMETERS[:Cancel_Button]	= ['Close',clicked]
  PARAMETERS[:Delete_Button]	= ['Delete Account',clicked]
  PARAMETERS[:Update_Button]	= ['Update Account',clicked]
  PARAMETERS[:Save_Button]	= ['Save To Disk',clicked]

  PARAMETERS[:Datafile_Button]	= ['Change Data File Password',clicked]

  PARAMETERS[:Current_Button]	= ['Clip Current Password',clicked]
  PARAMETERS[:Previous_Button]	= ['Clip Previous Password',clicked]
end
end

module Gtk2Password
module Configuration
  # Note that the passwords data file name is auto generated, but...
  # You can place your passwords data file in a directory other than ~/gtk2passwordapp-*
  PASSWORDS_DATA_DIR = Gtk2AppLib::USERDIR
  # Switches the roles of PRIMARY and CLIPBOARD when true
  SWITCH_CLIPBOARDS	= (Gtk2AppLib::HILDON || !Gtk2AppLib::Configuration::X)? true: false
  PASSWORD_EXPIRED	= 60*60*24*30*3 # 3 months
  URL_PATTERN		= Regexp.new('^https?:\/\/[^\s\']+$')
  DEFAULT_PASSWORD_LENGTH = 7
  EXPIRED_COLOR = Gtk2AppLib::Color[:Red]

  BAD_URL = ['Need url like http://www.site.com/page.html',{:TITLE => 'Error: Bad Url',:SCROLLED_WINDOW => false}]
  ARE_YOU_SURE = ['Changes will lost, are you sure you want to close?',{:TITLE => 'Are you sure?'}]
  WANT_TO_SAVE = ['Would you like to save your changes?',{:TITLE => 'Save?'}]
  NO_UPDATES = ["You've not updated any accounts yet.",{:TITLE => 'Not Modified',:SCROLLED_WINDOW => false}]
  UPDATED = ["Updated!",{:TITLE => 'Updated!',:SCROLLED_WINDOW => false}]

  updates = [:Delete_Button,:Update_Button,:Save_Button]
  updates.unshift(:Cancel_Button) if Gtk2AppLib::Configuration::MENU[:close]
  vbox = 'Gtk2AppLib::Widgets::VBox'
  hbox = 'Gtk2AppLib::Widgets::HBox'
  GUI = [
	['Gui',		vbox,	[:Account_Component,:Url_Component,:Note_Component,:Username_Component,:Password_Component,:Buttons_Component]],
	['Account',	hbox,	[:Account_Label,:Account_ComboBoxEntry]],
	['Url',		hbox,	[:Url_Label,:Url_Entry,:Url_Button]],
	['Note',	hbox,	[:Note_Label,:Note_Entry]],
	['Username',	hbox,	[:Username_Label,:Username_Entry]],
	['Password',	hbox,	[:Password_Label,:Password_Entry,:Password_CheckButton,:Password_SpinButton]],
	['Buttons',	vbox,	[:Generators_Component,:Updates_Component,:Datafile_Component,:Clip_Component]],
	['Generators',	hbox,	[:Random_Button,:Alpha_Button,:Numeric_Button,:Letters_Button,:Caps_Button]],
	['Updates',	hbox,	updates],
	['Datafile',	hbox,	[:Datafile_Button]],
	['Clip',	hbox,	[:Current_Button,:Previous_Button]],
    ]
end

  def self.passwords_updated(dumpfile)
    ## After the password files are saved, you have the option here to backup or mirror the files elsewhere.
    ## Here's an example:
    # system( "ssh user@192.168.1.123 mv .gtk2passwordapp-1/*.dat .gtk2passwordapp-1/bak/")
    # system( "ssh user@192.168.1.123 cp .gtk2passwordapp-1/passphrase.txt .gtk2passwordapp-1/bak/passphrase.txt") # you might choose not too.
    # fn = File.basename(dumpfile)
    # if system( "scp #{dumpfile} user@192.168.1.123:.gtk2passwordapp-1/#{fn}")	then
    # # again, you might choose not to distribute passphrase (reduces cracking to your short password)
    # if system( "scp #{Configuration::PASSWORDS_DATA_DIR}/passphrase.txt user@192.168.1.123:.gtk2passwordapp-1/passphrase.txt") then
    #   Gtk2AppLib::DIALOGS.quick_message("Passwords saved on 192.168.1.101 and 102")
    #   return
    # end
    # end
    # Gtk2AppLib::DIALOGS.quick_message("Warning: Could not create backup on 192.168.1.123")
    Gtk2AppLib::DIALOGS.quick_message("Passwords Data Saved.",{:TITLE => 'Saved',:SCROLLED_WINDOW => false})
  end
end
