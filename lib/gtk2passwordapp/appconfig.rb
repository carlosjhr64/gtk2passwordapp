# Note: you'll see in ~/.gtk2passwordapp-* a file called passphrase.txt.
# Do not edit or delete passphrase, or you'll loose your passwords data.

module Gtk2AppLib
module Configuration
  if HILDON then
    # WIDGET_OPTIONS[:font] = 
    FONT[:Normal] = FONT[:Large] = Pango::FontDescription.new( 'Arial 18' )
  end
  MENU[:close]		= '_Close'

  WINDOW_DEFAULT_SIZE[0],WINDOW_DEFAULT_SIZE[1] = 100,100
  padding = Widgets::WIDGET[:Widgets][:pack_start].last
  go = 50
  label = 75
  entry = 300
  spin = 60
  check = 20

  wrap		= {:wrap= => true}
  label_width	= {:width_request= => label, :wrap= => true}
  entry_width	= {:width_request= => entry}
  entry_shorten	= {:width_request= => entry - go - 2*padding}
  entry_shorten2 = {:width_request= => entry - spin - check - 4*padding, :visibility= => false}
  go_width	= {:width_request= => go}
  check_width	= {:width_request= => check, :active= => true}
  spin_width	= {:width_request= => spin, :set_range  => [3,30], :value= => 7}
  clicked	= 'clicked'

  PARAMETERS[:Account_Label]		= ['Account:',label_width]
  PARAMETERS[:Account_ComboBoxEntry]	= [[],entry_width]

  PARAMETERS[:Url_Label]	= ['Url:',label_width]
  PARAMETERS[:Url_Entry]	= [entry_shorten]
  PARAMETERS[:Url_Button]	= ['Go!',go_width,clicked]

  PARAMETERS[:Note_Label]	= ['Note:',label_width]
  PARAMETERS[:Note_Entry]	= [entry_width]

  PARAMETERS[:Username_Label]	= ['Username:',label_width]
  PARAMETERS[:Username_Entry]	= [entry_width]

  PARAMETERS[:Password_Label]	= ['Password:',label_width]
  PARAMETERS[:Password_Entry]	= [entry_shorten2]
  PARAMETERS[:Password_CheckButton]	= [check_width]
  PARAMETERS[:Password_SpinButton]	= [spin_width]

  PARAMETERS[:Random_Button]	= ['Random',clicked]
  PARAMETERS[:Alpha_Button]	= ['Alpha-Numeric',clicked]
  PARAMETERS[:Numeric_Button]	= ['Numeric',clicked]
  PARAMETERS[:Letters_Button]	= ['Letters',clicked]
  PARAMETERS[:Caps_Button]	= ['All-Caps',clicked]

  PARAMETERS[:Cancel_Button]	= ['Cancel All Changes',clicked]
  PARAMETERS[:Delete_Button]	= ['Delete Account',clicked]
  PARAMETERS[:Update_Button]	= ['Update Account',clicked]
  PARAMETERS[:Save_Button]	= ['Save To Disk',clicked]

  PARAMETERS[:Datafile_Button]	= ['Change Data File Password',clicked]

  PARAMETERS[:Current_Button]	= ['Clip Current Password',clicked]
  PARAMETERS[:Previous_Button]	= ['Clip Previous Password',clicked]
end
end

module Gtk2PasswordApp
module Configuration
  # Note that the passwords data file name is auto generated, but...
  # You can place your passwords data file in a directory other than ~/gtk2passwordapp-*
  PASSWORDS_DATA_DIR = Gtk2AppLib::USERDIR

  # Switches the roles of PRIMARY and CLIPBOARD when true
  SWITCH_CLIPBOARDS	= (Gtk2AppLib::HILDON)? true: false

  PASSWORD_EXPIRED	= 60*60*24*30*3 # 3 months

  URL_PATTERN		= Regexp.new('^https?:\/\/[^\s\']+$')

  DEFAULT_PASSWORD_LENGTH = 7
end

  def self.passwords_updated(dumpfile)
    ## After the password files are saved, you have the option here to backup or mirror the files elsewhere.
    ## Here's a example:
    # system( "ssh user@192.168.1.123 mv .gtk2passwordapp-1/*.dat .gtk2passwordapp-1/bak/")
    # fn = File.basename(dumpfile)
    # if system( "scp #{dumpfile} user@192.168.1.123:.gtk2passwordapp-1/#{fn}")	then
    # if system( "scp #{Configuration::PASSWORDS_DATA_DIR}/passphrase.txt user@192.168.1.123:.gtk2passwordapp-1/passphrase.txt") then
    #   Gtk2AppLib::DIALOGS.quick_message("Passwords saved on 192.168.1.101 and 102")
    #   return
    # end
    # end
    # Gtk2AppLib::DIALOGS.quick_message("Warning: Could not create backup on 192.168.1.123")
  end
end
