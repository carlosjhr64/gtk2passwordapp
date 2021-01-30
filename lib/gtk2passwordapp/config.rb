class Gtk2PasswordApp
  using Rafini::String
  extend Rafini::Empty

  CONFIG = {
    HelpFile: 'https://github.com/carlosjhr64/gtk2passwordapp',
    Logo: "#{UserSpace::XDG['data']}/gtk3app/gtk2passwordapp/logo.png",
    HiddenPwd: ' * * * ',

    # Tools Button

    tool_button: h0,

    # Tools Labels

    ADD:  [label: 'Add'],
    EDIT: [label: 'Edit'],
    SHOW: [label: 'Show'],
    GO:   [label: 'Go'],
  # Current:  'Current',
  # Previous: 'Previous',
  # Cancel:   'Cancel',
  # Delete:   'Delete',
  # Save:     'Save',

    # Initialize
    # Stage and Toolbar

    ClipboardTimeout: 15,
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
    field_label: {set_selectable: true},
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

    SUBMIT_BUTTON: [label:'Submit'], # TODO: probably goes away
    submit_button: h0,
    submit_button!: [:SUBMIT_BUTTON,:submit_button],

    # Errors

    BadUrl: 'URL must be like http://site.',
    BadUsername: 'Username must be all graph.',
    BadPassword: 'Password must be all graph.',
    BadName: 'Account name must be a non-empty String.',

    # About Dialog

    about_dialog: {
      set_program_name: 'Password Manager',
      set_version: VERSION.semantic(0..1),
      set_copyright: '(c) 2021 CarlosJHR64',
      set_comments: 'A Gtk3App Password Manager',
      set_website: 'https://github.com/carlosjhr64/gtk2passwordapp',
      set_website_label: 'See it at GitHub!',
    },

  }
end
