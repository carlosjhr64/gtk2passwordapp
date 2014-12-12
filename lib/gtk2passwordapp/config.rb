module Gtk2passwordapp
  APPDIR = File.dirname File.dirname __dir__

  s0 = Rafini::Empty::STRING
  h0 = Rafini::Empty::HASH
  a0 = Rafini::Empty::ARRAY

  CONFIG = {

    # Password Data File
    PwdFile: "#{XDG['CACHE']}/gtk3app/gtk2passwordapp/passwords.dat",

    # Password Generators
    Random:       'Random',
    AlphaNumeric: 'Alpha-Numeric',
    Custom:       'Caps',
    CustomDigits: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',

    # Button Labels
    Quit:     'Quit',
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
    Delete?: 'Delete?',

    # Colors
    GoodColor: '#00F',
    BadColor:  '#F00',

    # Clipboard
    SwitchClipboard: false,
    ClipboardTimeout: 15,

    Name: 'Account:',
    FIELDS: [
      [:url,      'Url:'     ],
      [:note,     'Note:'    ],
      [:username, 'Username:'],
      [:password, 'Password:'],
    ],

    thing: {

      box:    h0,
      label:  h0,
      entry:  h0,
      button: h0,
      check_button: h0,
      spin_button: h0,

      vbox!: [[:vertical],   :box, s0],
      hbox!: [[:horizontal], :box, s0],

      prompt!:   [a0, h0],
      prompted!: [a0, h0],

      a!: [a0, :button],
      b!: [a0, :button],
      c!: [a0, :button],

      window: {
        set_title: 'Password Manager',
        set_window_position: :center,
      },

      password_label!: [['Password:'], :label],
      password_entry!: [a0, {set_visibility: false}],

      edit_label!:     [['Edit Account'], :label],
      add_label!:      [['Add Account'],  :label],
      view_label!:     [['View Account'], :label],

      pwd_size_check!: [:check_button],
      pwd_size_spin!: [
        {
          set_range: [4,64],
          set_increments: [1,10],
          set_digits: 0,
          set_value: 14,
        },
      ],

      delete_dialog: {
        set_window_position: :center_on_parent,
        set_keep_above: true,
      },
      delete_dialog!: [a0, :delete_dialog],

      about_dialog: {
        set_program_name: 'Password Manager',
        set_version: VERSION,
        set_copyright: '(c) 2014 CarlosJHR64',
        set_comments: 'A Gtk3App Password Manager',
        set_website: 'https://github.com/carlosjhr64/gtk2passwordapp',
        set_website_label: 'See it at GitHub!',
      },
      HelpFile: 'https://github.com/carlosjhr64/gtk2passwordapp',
      Logo: "#{XDG['DATA']}/gtk3app/gtk2passwordapp/logo.png",

    }
  }
end

Such::Parts.make('AbButtons', 'Box', :a_Button, :b_Button)
Such::Parts.make('AbcButtons', 'Box', :a_Button, :b_Button, :c_Button)

Such::Parts.make('PromptedEntryLabel', 'Box', :prompt_Label, :prompted_Entry, :prompted_Label)
Such::Parts.make('PromptedEntry', 'Box', :prompt_Label, :prompted_Entry)
Such::Parts.make('PromptedLabel', 'Box', :prompt_Label, :prompted_Label)
Such::Parts.make('PromptedCombo', 'Box', :prompt_Label, :prompted_ComboBoxText)
