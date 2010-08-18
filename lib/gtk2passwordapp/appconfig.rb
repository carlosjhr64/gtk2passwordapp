# Note: you'll see in ~/.gtk2passwordapp-* a file called passphrase.txt.
# Do not edit or delete passphrase, or you'll loose your passwords data.

module Gtk2AppLib
module Configuration
  # Note that the passwords data file name is auto generated, but...
  # You can place your passwords data file in a directory other than ~/gtk2passwordapp-*
  PASSWORDS_DATA_DIR = UserSpace::DIRECTORY

  HILDON = (WRAPPER.to_s =~ /HildonWrapper/)? true: false

  GO_BUTTON_LENGTH	= 50
  SPIN_BUTTON_LENGTH	= 60
  PADDING		= 2
  ENTRY_WIDTH		= (HILDON)? 600: 300
  LABEL_WIDTH		= 75


  # Switches the roles of PRIMARY and CLIPBOARD when true
  SWITCH_CLIPBOARDS	= HILDON

  PASSWORD_EXPIRED	= 60*60*24*30*3 # 3 months

  URL_PATTERN		= Regexp.new('^https?:\/\/[^\s\']+$')

  if HILDON then
    WIDGET_OPTIONS[:font] = FONT[:normal] = FONT[:large] = Pango::FontDescription.new( 'Arial 18' )
  end

  MENU[:close]		= '_Close'

  WINDOW_DEFAULT_SIZE[0],WINDOW_DEFAULT_SIZE[1] = 100,100

  WIDGET_OPTIONS[:max]		= 20 # MAX PASSWORD LENGTH
  WIDGET_OPTIONS[:min]		= 3  # MIN PASSWORD LENGTH
  DEFAULT_PASSWORD_LENGTH = 7

  WIDGET_OPTIONS[:spinbutton_width] = SPIN_BUTTON_LENGTH
  WIDGET_OPTIONS[:padding]	= PADDING
end

  def self.passwords_updated(dumpfile)
    # After the password files are saved, you have the option here to backup or mirror the files elsewhere....
   #fn = File.basename(dumpfile)
   #system( "scp #{dumpfile} user@192.168.1.123:.gtk2passwordapp-1/#{fn}")
   #system( "scp #{Configuration::PASSWORDS_DATA_DIR}/passphrase.txt user@192.168.1.123:.gtk2passwordapp-1/passphrase.txt")
  end
end
