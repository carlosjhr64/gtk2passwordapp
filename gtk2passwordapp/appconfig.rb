# Note: you'll see in ~/.gtk2passwordapp-* a file called passphrase.txt.
# Do not edit or delete passphrase, or you'll loose your passwords data.

module Configuration
  # Note that the passwords data file name is auto generated, but...
  # You can place your passwords data file in a directory other than ~/gtk2passwordapp-*
  PASSWORDS_DATA_DIR = UserSpace::DIRECTORY

  ENTRY_WIDTH	= (Gtk2App::HILDON)? 600: 300
  LABEL_WIDTH	= 75
  GO_BUTTON_LENGTH = 50
  SPIN_BUTTON_LENGTH = 60
  PAD		= 2	# cell padding

  MAX_PASSWORD_LENGTH = 20
  DEFAULT_PASSWORD_LENGTH = 7
  MIN_PASSWORD_LENGTH = 3

  # Switches the roles of PRIMARY and CLIPBOARD when true
  SWITCH_CLIPBOARDS = Gtk2App::HILDON

  PASSWORD_EXPIRED = 60*60*24*30*3 # 3 months

  URL_PATTERN	= Regexp.new('^https?:\/\/[^\s\']+$')

  FONT[:normal] = FONT[:large] = Pango::FontDescription.new( 'Arial 18' )	if Gtk2App::HILDON
  GUI[:window_size] = [100,100]
  MENU[:close]  = '_Close'
end
