require 'gtk2passwordapp/passwords'
module Gtk2PasswordApp

  PRIMARY	= Gtk::Clipboard.get((Configuration::SWITCH_CLIPBOARDS)? Gdk::Selection::CLIPBOARD: Gdk::Selection::PRIMARY)
  CLIPBOARD	= Gtk::Clipboard.get((Configuration::SWITCH_CLIPBOARDS)? Gdk::Selection::PRIMARY: Gdk::Selection::CLIPBOARD)

  @@index = 0
  def self.index
    @@index
  end
  def self.build_menu(program,passwords)
    if program.icon? then
      program.clear_dock_menu
      program.append_dock_menu(Gtk::SeparatorMenuItem.new)
      passwords.accounts.each do |account|
        item = program.append_dock_menu(account) do
          @@index = passwords.accounts.index(account)
          PRIMARY.text   = passwords.password_of(account)
          CLIPBOARD.text = passwords.username_of(account)
        end
        item.child.modify_fg(Gtk::STATE_NORMAL, Configuration::EXPIRED_COLOR) if passwords.expired?(account)
      end
    end
  end

  def self.save(program,passwords)
    dumpfile = passwords.save
    Gtk2PasswordApp.passwords_updated(dumpfile)
    Gtk2PasswordApp.build_menu(program,passwords)
  end

  def self.get_salt(prompt,title=prompt)
    Gtk2AppLib::DIALOGS.entry( prompt, {:Title=>title, :Entry => [{:visibility= => false},'activate']} )
  end

  def self.account( shared = Component::SHARED )
    account = (shared[:Account_ComboBoxEntry].active_text)? shared[:Account_ComboBoxEntry].active_text.strip: ''
    (account.length>0)? account: nil
  end

  def self.clicked(is,passwords)

    shared = Component::SHARED
    pwdlength = shared[:Password_SpinButton]
    account = Gtk2PasswordApp.account

    case is

    when shared[:Url_Button]
      url = shared[:Url_Entry].text.strip
      Gtk2AppLib.run(url) if url =~ Configuration::URL_PATTERN

    when shared[:Random_Button]
      suggestion = ''
      pwdlength.value.to_i.times do
        suggestion += (rand(94)+33).chr
      end
      shared[:Password_Entry].text = suggestion

    when shared[:Alpha_Button]
      suggestion = ''
      while suggestion.length <  pwdlength.value.to_i do
        chr = (rand(75)+48).chr
        suggestion += chr if chr =~/\w/
      end
      shared[:Password_Entry].text = suggestion

    when shared[:Numeric_Button]
      suggestion = ''
      pwdlength.value.to_i.times do
        chr = (rand(10)+48).chr
        suggestion += chr
      end
      shared[:Password_Entry].text = suggestion

    when shared[:Letters_Button]
      suggestion = ''
      while suggestion.length < pwdlength.value.to_i do
        chr = (rand(58)+65).chr
        suggestion += chr if chr =~/[A-Z]/i
      end
      shared[:Password_Entry].text = suggestion

    when shared[:Caps_Button]
      suggestion = ''
      pwdlength.value.to_i.times do
        chr = (rand(26)+65).chr
        suggestion += chr
      end
      shared[:Password_Entry].text = suggestion

    when shared[:Delete_Button]
      # MODIFIES!!!
      if account then
        i = passwords.accounts.index(account)
        if i then
          passwords.delete(account)
          shared[:Account_ComboBoxEntry].remove_text(i)
          @@index = (shared[:Account_ComboBoxEntry].active = (i > 0)? i - 1: 0)
          yield(:modified)
        end
      end

    when shared[:Update_Button]
      # MODIFIES!!!
      if account then
        url = shared[:Url_Entry].text.strip
        if url.length == 0 || url =~ Configuration::URL_PATTERN then
          yield(:modified)
          if !passwords.include?(account) then
            passwords.add(account) 
            @@index = i = passwords.accounts.index(account)
            shared[:Account_ComboBoxEntry].insert_text(i,account)
          end
          passwords.url_of(account, url)
          passwords.note_of(account, shared[:Note_Entry].text.strip)
          passwords.username_of(account, shared[:Username_Entry].text.strip)
          password = shared[:Password_Entry].text.strip
          passwords.password_of(account, password) if !passwords.verify?(account, password)
          Gtk2AppLib::DIALOGS.quick_message(*Configuration::UPDATED)
        else
          Gtk2AppLib::DIALOGS.quick_message(*Configuration::BAD_URL)
        end
      end

    when shared[:Datafile_Button]
      if pwd1 = Gtk2PasswordApp.get_salt('New Password') then
        if pwd2 = Gtk2PasswordApp.get_salt('Verify') then
          while !(pwd1==pwd2) do
            pwd1 = Gtk2PasswordApp.get_salt('Try again!')
            return if !pwd1
            pwd2 = Gtk2PasswordApp.get_salt('Verify')
            return if !pwd2
          end
          dumpfile = passwords.save(pwd1)
          Gtk2PasswordApp.passwords_updated(dumpfile)
        end
      end

    when shared[:Current_Button]
      if account then
        PRIMARY.text = passwords.password_of(account)
        CLIPBOARD.text = passwords.username_of(account)
      end

    when shared[:Previous_Button]
      if account then
        PRIMARY.text = passwords.previous_password_of(account)
        CLIPBOARD.text = passwords.username_of(account)
      end

    when shared[:Save_Button]	then yield(:save)
    when shared[:Cancel_Button]	then yield(:close)
    else $stderr.puts "What? #{is} in #{is.parent.class}."
    end

  end

  def self.changed(is,passwords)
    shared = Component::SHARED
    account = Gtk2PasswordApp.account
    case is
    when shared[:Account_ComboBoxEntry]
      if account then
        shared[:Password_Entry].text	= ''
        if passwords.include?(account) then
          shared[:Url_Entry].text	= passwords.url_of(account)
          shared[:Note_Entry].text	= passwords.note_of(account)
          shared[:Username_Entry].text	= passwords.username_of(account)
          shared[:Password_Entry].text	= passwords.password_of(account)
        else
          shared[:Url_Entry].text	= ''
          shared[:Note_Entry].text	= ''
          shared[:Username_Entry].text	= ''
        end
        @@index = is.active
        $stderr.puts "Index: #{@@index}" if $trace
      end
    else
      $stderr.puts "What? Expected #{shared[:Account_ComboBoxEntry]}, got #{is}."
    end
  end

  def self.toggled(is,passwords)
    pwd = Component::SHARED[:Password_Entry]
    pwd.visibility = !pwd.visibility?
  end

  module Component
    SHARED = {}

    updates = [:Delete_Button,:Update_Button,:Save_Button]
    updates.unshift(:Cancel_Button) if Gtk2AppLib::Configuration::MENU[:close]

    vbox = 'Gtk2AppLib::Widgets::VBox'
    hbox = 'Gtk2AppLib::Widgets::HBox'
    classes = [
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
    classes.each do |clss,spr,keys|
      code = Gtk2AppLib::Component.define(clss,spr,keys)
      $stderr.puts "<<<START CODE EVAL>>>\n#{code}\n<<<END CODE EVAL>>>" if $trace && $verbose
      eval( code )
    end

    def self.init_code(clss,keys)
      code = <<-EOT
        class #{clss}
          def _init(block)
      EOT
      keys.each do |key|
        code += <<-EOT
            SHARED[:#{key}] = self.#{key.to_s.downcase}
        EOT
      end
      code += <<-EOT
          end
        end
      EOT
      code
    end

    # Regardless of where in the gui they are...
    [	['Account',	[:Account_ComboBoxEntry]],
	['Url',		[:Url_Entry,:Url_Button]],
	['Note',	[:Note_Entry]],
	['Username',	[:Username_Entry]],
	['Password',	[:Password_Entry,:Password_SpinButton]],
	['Generators',	[:Random_Button,:Alpha_Button,:Numeric_Button,:Letters_Button,:Caps_Button]],
	['Updates',	updates],
	['Datafile',	[:Datafile_Button]],
	['Clip',	[:Current_Button,:Previous_Button]],
    ].each do |clss,keys|
      code = Component.init_code(clss,keys) 
      $stderr.puts "<<<START CODE EVAL>>>\n#{code}\n<<<END CODE EVAL>>>" if $trace && $verbose
      eval( code )
    end

  end
end
