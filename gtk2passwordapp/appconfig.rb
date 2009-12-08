# Note: you'll see in ~/.gtk2passwordapp-* a file called passphrase.txt.
# Do not edit or delete passphrase, or you'll loose your passwords data.

module Configuration
  # Note that the passwords data file name is auto generated, but...
  # You cam place your passwords data file in a directory other than ~/gtk2passwordapp-*
  PASSWORDS_DATA_DIR = UserSpace::DIRECTORY

  ENTRY_WIDTH	= 275
  LABEL_WIDTH	= 75
  SPIN_BUTTON_LENGTH = 50
  PAD		= 2	# cell padding

  MAX_PASSWORD_LENGTH = 20
  DEFAULT_PASSWORD_LENGTH = 7
  MIN_PASSWORD_LENGTH = 3

  VERIFIED_EXPIRED = 60*60 # one hour
  PASSWORD_EXPIRED = 60*60*24*30*3 # 3 months

  URL_PATTERN	= Regexp.new('^https?:\/\/[^\s\']+$')

  MENU[:close]  = '_Close'
end
