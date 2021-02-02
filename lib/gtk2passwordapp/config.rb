class Gtk2PasswordApp
  using Rafini::String
  extend Rafini::Empty

  H2Q = BaseConvert::FromTo.new(base: 16, digits: '0123456789ABCDEF', to_base:91, to_digits: :qgraph)
  RND = SuperRandom.new
  TOTPx = /^[A-Z2-7]{16,}$/

  CONFIG = {

    # Hashing

    Salt: s0,
    LongPwd: 14,

    # Miscellaneous Strings

    Logo: "#{UserSpace::XDG['data']}/gtk3app/gtk2passwordapp/logo.png",
    HiddenPwd: ' * * * ',

    # Overriding Gtk3App's window, main:

    main: { set_title: 'Password Manager' },

    # Overriding Gtk3App's toolbar
    toolbar: {
      set_expanded: true,
      into: [:pack_start, expand:true, fill:true, padding:4],
    },

    # Overriding Gtk3App's app_menu:

    app_menu: {
      add_menu_item: [:minime!,:about!,:quit!],
    },

    # Colors

    Red: '#900',
    Green: '#090',
    Blue: '#009',
    TooOld: 60*60*24*365, # Year

    # Buttons

    tool_button: {
      set_width_request: 1,
      into: [:pack_start, expand:true, fill:true, padding:1],
    },

    # Spin Buttons

    PWDLEN: [3,40,1],
    pwdlen: {set_value: 13},
    pwdlen!: [:PWDLEN,:pwdlen],

    # Tools Labels

    ADD:      [label: 'Add'],
    EDIT:     [label: 'Edit'],
    GO:       [label: 'Go'],
    CANCEL:   [label: 'Cancel'],
    DELETE:   [label: 'Delete'],
    SAVE:     [label: 'Save'],
    CURRENT:  [label: 'Current'],
    PREVIOUS: [label: 'Previous'],
    RAND:     [label: 'Random'],

    # Initialize
    # Stage and Toolbar

    ClipboardTimeout: 15,
    PwdFile: "#{UserSpace::XDG['cache']}/gtk3app/gtk2passwordapp/dump.yzb",

    # Logo's Main Menu

    MAIN_MENU: a0,
    main_menu: h0,
    main_menu!: [:MAIN_MENU,:main_menu],

    main_menu_item: h0,

    # Toolbar's Toolbox

    TOOLBOX: [:horizontal],
    toolbox: h0,
    toolbox!: [:TOOLBOX,:toolbox],

    # Stage's Pages

    PAGES: [:vertical],
    pages: h0,
    pages!: [:PAGES,:pages],

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
    field_label: {
      set_selectable: false,
      set_width_request: 80,
      set_alignment: [1.0,0.5],
      set_padding: [4,4],
    },
    field_label!: [:FIELD_LABEL, :field_label],

    # Field View

    FIELD_VIEW: a0,
    field_view: {
      set_selectable: true,
      set_width_request: 250,
      set_alignment: [0.0,0.5],
      set_padding: [4,4],
    },
    field_view!: [:FIELD_VIEW, :field_view],

    # Field Entry

    FIELD_ENTRY: a0,
    field_entry: {
      set_width_request: 250,
      into: [:pack_start, expand:true, fill:true, padding:4],
    },
    field_entry!: [:FIELD_ENTRY,:field_entry],

    # Password Entry

    PASSWORD_ENTRY: a0,
    password_entry: {
      set_visibility: false,
      set_width_request: 250,
      into: [:pack_start, expand:true, fill:true, padding:4],
    },
    password_entry!: [:PASSWORD_ENTRY,:password_entry],

    # Error Label

    ERROR_LABEL: a0,
    error_label: h0,
    error_label!: [:ERROR_LABEL,:error_label],

    # Password Page

    MinPwdLen: 7,
    Confirm: "Confirm password!",

    # Page Labels

    PASSWORD_PAGE_LABEL: ['Enter Master Password'],
    ADD_PAGE_LABEL: ['Add Account'],
    EDIT_PAGE_LABEL: ['Edit Account'],
    MAIN_PAGE_LABEL: ['View Account'],

    # Fields

    NAME: ['Name:'],
    URL: ['URL:'],
    NOTE: ['Note:'],
    USERNAME: ['Username:'],
    PASSWORD: ['Password:'],

    # About Dialog

    about_dialog: {
      set_program_name: 'Password Manager',
      set_version: VERSION.semantic(0..1),
      set_copyright: '(c) 2021 CarlosJHR64',
      set_comments: 'A Gtk3App Password Manager',
      set_website: 'https://github.com/carlosjhr64/gtk2passwordapp',
      set_website_label: 'See it at GitHub!',
    },

    # Delete Dialog

    DELETE_URSURE: a0,
    delete_ursure: {add_label: 'Delete?'},
    delete_ursure!: [:DELETE_URSURE,:delete_ursure],

    # Reset Dialog

    RESET_URSURE: a0,
    reset_ursure: {add_label: 'Reset Master Password?'},
    reset_ursure!: [:RESET_URSURE,:reset_ursure],

    # Errors

    BadUrl: 'URL must be like http://site.',
    BadUsername: 'Username must be all graph.',
    BadPassword: 'Password must be all graph.',
    BadName: 'Account name must be a non-empty String.',
    CipherError: 'Decryption error.',
    AccountHit: 'Account exists.',
    AccountMiss: 'Account does NOT exist.',
    TooShort: "Password too short!",

  }
end
