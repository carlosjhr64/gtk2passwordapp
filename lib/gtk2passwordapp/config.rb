class Gtk2PasswordApp
  using Rafini::String
  extend Rafini::Empty

  CONFIG = {
    HelpFile: 'https://github.com/carlosjhr64/gtk2passwordapp',
    Logo: "#{UserSpace::XDG['data']}/gtk3app/gtk2passwordapp/logo.png",

    # Initialize
    # Stage and Toolbar

    PwdFile: "#{UserSpace::XDG['cache']}/gtk3app/gtk2passwordapp/dump.yzb",
    BackupFile: File.expand_path('~/Dropbox/gtk2passwordapp.yzb'),

    MAIN_MENU: a0,
    main_menu: h0,
    main_menu!: [:MAIN_MENU,:main_menu],

    main_menu_item: h0,

    TOOLBOX: [:horizontal],
    toolbox: h0,
    toolbox!: [:TOOLBOX,:toolbox],

    PAGES: [:vertical],
    pages: h0,
    pages!: [:PAGES,:pages],

    # Rehash

    Salt: s0,
    LongPwd: 14,

    # Page

    PAGE: [:vertical],
    page: h0,
    page!: [:PAGE,:page],

    # Page Label

    page_label: h0,

    # Field Row

    FIELD_ROW: [:horizontal],
    field_row: h0,
    field_row!: [:FIELD_ROW,:field_row],

    # Field Label

    FIELD_LABEL: a0,
    field_label: h0,
    field_label!: [:FIELD_LABEL, :field_label],

    # Field Entry

    FIELD_ENTRY: a0,
    field_entry: h0,
    field_entry!: [:FIELD_ENTRY,:field_entry],

    # Password Entry

    PASSWORD_ENTRY: a0,
    password_entry: {set_visibility: false},
    password_entry!: [:PASSWORD_ENTRY,:password_entry],

    # Error Label

    ERROR_LABEL: a0,
    error_label: h0,
    error_label!: [:ERROR_LABEL,:error_label],

    # Password Page

    MinPwdLen: 7,
    TooShort: "Password too short!",
    Confirm: "Confirm password!",

    # Page Labels

    ADD_PAGE_LABEL: ['Add Account'],
    EDIT_PAGE_LABEL: ['Edit Account'],
    MAIN_PAGE_LABEL: ['View Account'],

    # Fields

    NAME: ['Name:'],
    URL: ['URL:'],
    NOTE: ['Note:'],
    USERNAME: ['Username:'],
    PASSWORD: ['Password:'],

    SUBMIT_BUTTON: [label:'Submit'],
    submit_button: h0,
    submit_button!: [:SUBMIT_BUTTON,:submit_button],

    # Errors

    BadUrl: 'URL must be like http://site.',
    BadUsername: 'Username must be all graph.',
    BadPassword: 'Password must be all graph.',
    BadName: 'Account name must be a non-empty String.',

  }
end
=begin
    HiddenPwd: ' * * * ',

    TOTP: '^[A-Z2-7]{16,}$', # TODO: not being used?

    # Mark Recent Selections
    Recent: 7,

    # Mark Old Passwords
    TooOld: 60*60*24*365, # Year

    # Password Generators
    Random:       'Random',
    AlphaNumeric: 'Alpha-Numeric',
    Custom:       'Custom',
    CustomDigits: BaseConvert::DIGITS[:unambiguous],

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

    reset!:  [[label: 'Reset Master Password'], 'activate'],
    backup!: [[label: 'Backup Passwords'],      'activate'],

    about_dialog: {
      set_program_name: 'Password Manager',
      set_version: VERSION.semantic(0..1),
      set_copyright: '(c) 2017 CarlosJHR64',
      set_comments: 'A Gtk3App Password Manager',
      set_website: 'https://github.com/carlosjhr64/gtk2passwordapp',
      set_website_label: 'See it at GitHub!',
    },

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
end
=end
