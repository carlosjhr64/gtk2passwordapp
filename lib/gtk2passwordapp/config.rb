module Gtk2passwordapp
  using Rafini::String

  help = <<-HELP
Usage:
  gtk3app gtk2passwordapp [--help] [--version]
  gtk2passwordapp [--no-gui [--dump [--verbose]]] [account]
  HELP

  APPDIR = File.dirname File.dirname __dir__

  s0 = Rafini::Empty::STRING
  h0 = Rafini::Empty::HASH
  a0 = Rafini::Empty::ARRAY

  CONFIG = {
    Help: help,

    # Password Data File
    PwdFile: "#{XDG['CACHE']}/gtk3app/gtk2passwordapp/passwords.dat",
    # Shared Secret File
    # Consider using a file found in a removable flashdrive.
    SharedSecretFile: "#{XDG['CACHE']}/gtk3app/gtk2passwordapp/key.ssss",
    BackupFile: "#{ENV['HOME']}/Dropbox/gtk2passwordapp.bak",

    # Mark Recent Selections
    Recent: 7,

    # Mark Old Passwords
    TooOld: 60*60*24*365, # Year

    # Timeout for qr-code read.
    QrcTimeOut: 3,

    # Password Generators
    Random:       'Random',
    AlphaNumeric: 'Alpha-Numeric',
    Custom:       'Caps',
    CustomDigits: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',

    # Button Labels
    Go:       'Go',
    Edit:     'Edit',
    Add:      'Add',
    Goto:     'Goto',
    Current:  'Current',
    Previous: 'Previous',
    Show:     'Show',
    Cancel:   'Cancel',
    Delete:   'Delete',
    Save:     'Save',

    # Labels
    ReTry:   'Try Again!',
    HiddenPwd: ' * * * ',

    # Colors
    Blue:  '#00F',
    Red:   '#F00',
    Black: '#000',

    # Clipboard
    SwitchClipboard: false,
    ClipboardTimeout: 15,

    # Fields' Labels
    Name: 'Account:',
    FIELDS: [
      [:url,      'Url:'     ],
      [:note,     'Note:'    ],
      [:username, 'Username:'],
      [:password, 'Password:'],
    ],
    FIELD_ALIGNMENT: [0.0, 0.5],

    # Such::Thing::PARAMETERS
    thing: {

      box:          h0,
      label:        h0,
      check_button: h0,
      entry:        h0,

      button:       {
        set_width_request: 75,
        into: [:pack_start, expand:true, fill:true, padding:0],
      },

      vbox!: [[:vertical],   :box, s0],
      hbox!: [[:horizontal], :box, s0],

      prompt: {
        set_width_request: 75,
        set_alignment: [1.0, 0.5],
        set_padding: [4,4],
      },
      prompt!:   [a0, :prompt],

      prompted: {
        set_width_request: 325,
      },
      prompted!: [a0, :prompted],

      a!: [a0, :button],
      b!: [a0, :button],
      c!: [a0, :button],

      window: {
        set_title: 'Password Manager',
        set_window_position: :center,
      },

      password_label!: [['Password:'], :label],
      password_entry!: [a0, :entry, {set_visibility: false}],

      edit_label!:     [['Edit Account'], :label],
      add_label!:      [['Add Account'],  :label],
      view_label!:     [['View Account'], :label],

      pwd_size_check!: [:check_button],
      pwd_size_spin!: [
        [4,64,1],
        {
          set_increments: [1,10],
          set_digits: 0,
          set_value: 14,
        },
      ],

      reset!:  [['Reset Master Password'], 'activate'],
      backup!: [['Backup Passwords'],      'activate'],

      about_dialog: {
        set_program_name: 'Password Manager',
        set_version: VERSION.semantic(0..1),
        set_copyright: '(c) 2014 CarlosJHR64',
        set_comments: 'A Gtk3App Password Manager',
        set_website: 'https://github.com/carlosjhr64/gtk2passwordapp',
        set_website_label: 'See it at GitHub!',
      },
      HelpFile: 'https://github.com/carlosjhr64/gtk2passwordapp',
      Logo: "#{XDG['DATA']}/gtk3app/gtk2passwordapp/logo.png",

      backup_dialog: {
        set_title: 'Backup Passwords',
        set_window_position: :center_on_parent,
      },

      error_dialog: {
        set_text: 'Backup Error',
        set_window_position: :center_on_parent,
      },

      delete_dialog: {
        set_window_position: :center_on_parent,
      },
      delete_label!:   [['Delete?'],      :label],

    }
  }
end
