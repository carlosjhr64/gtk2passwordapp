require 'gtk2passwordapp/passwords'
require 'gtk2passwordapp/rnd'

module Gtk2Password

  ABOUT		= {
	'name'		=> 'Ruby-Gnome Password Manager II',
	'authors'	=> ['carlosjhr64@gmail.com'],
	'website'	=> 'https://sites.google.com/site/gtk2applib/home/gtk2applib-applications/gtk2passwordapp',
	'website-label'	=> 'Ruby-Gnome Password Manager',
        'license'        => 'GPL',
        'copyright'      => '2011-09-19 12:00:24',
  }

  PRIMARY	= Gtk::Clipboard.get((Configuration::SWITCH_CLIPBOARDS)? Gdk::Selection::CLIPBOARD: Gdk::Selection::PRIMARY)
  CLIPBOARD	= Gtk::Clipboard.get((Configuration::SWITCH_CLIPBOARDS)? Gdk::Selection::PRIMARY: Gdk::Selection::CLIPBOARD)

  @@thread = nil
  def self.clear_clipboard
    @@thread.kill if !@@thread.nil?
    @@thread = Thread.new do
      sleep Configuration::CLIPBOARD_TIMEOUT
      PRIMARY.text	= ''
      CLIPBOARD.text	= ''
    end
  end

  Passwords::PROMPT[:password]	= Configuration::PASSWORD
  Passwords::PROMPT[:again]	= Configuration::AGAIN
  Passwords::PROMPT[:retry]	= Configuration::RETRY

  Configuration::GUI.each do |clss,spr,keys|
    code = Gtk2AppLib::Component.define(clss,spr,keys)
    $stderr.puts "<<<START CODE EVAL>>>\n#{code}\n<<<END CODE EVAL>>>" if $trace && $verbose
    eval( code )
  end

  # App is an App is an App...
  class App
    @@index = 0

    def initialize(program)
      @program		= program
      @passwords	= Gtk2Password::Passwords.new(Configuration::PASSWORDS_FILE) do |prompt|
        Gtk2Password.get_password(prompt)	|| exit
      end
      @passwords.expired = Configuration::PASSWORD_EXPIRED
      @modified		= false
      self.build_menu
      program.window do |window|
        @window	= window
        self.pre_gui
        @gui	= self.build_gui
        self.post_gui
      end
    end

    def menu_item(account)
      item = @program.append_dock_menu(account) do
        @@index	= @passwords.accounts.index(account)
        PRIMARY.text	= @passwords.password_of(account)
        CLIPBOARD.text	= @passwords.username_of(account)
        Gtk2Password.clear_clipboard
      end
      item.child.modify_fg(Gtk::STATE_NORMAL, Configuration::EXPIRED_COLOR)	if @passwords.expired?(account)
    end

    def build_menu
      if @program.icon? then
        @program.clear_dock_menu
        @program.append_dock_menu(Gtk::SeparatorMenuItem.new)
        @passwords.accounts.each{|account| menu_item(account)}
      end
    end

    def _save
      @passwords.save
      Gtk2Password.passwords_updated
      build_menu
    end

    def save
      if @modified then
        _save
        @modified = false
      else
        Gtk2AppLib::DIALOGS.quick_message(*Gtk2Password::Configuration::NO_UPDATES)
      end
    end

    def finalyze
      if @modified then
        if Gtk2AppLib::DIALOGS.question?(*Gtk2Password::Configuration::WANT_TO_SAVE) then
          save
          @modified = false
        end
      end
      if @modified then
        @passwords.load # revert
        @modified = false
      end
    end

    def post_gui
      @gui[:password_spinbutton].value = Gtk2Password::Configuration::DEFAULT_PASSWORD_LENGTH
      @gui[:account_comboboxentry].active = @@index
      @window.signal_connect('destroy'){ finalyze }
      @window.show_all
    end

    def pre_gui
      Gtk2AppLib::Configuration::PARAMETERS[:Account_ComboBoxEntry][0] = @passwords.accounts
      Gtk2AppLib::Dialogs::DIALOG[:Window] = @window
    end

    def close
      if !@modified || Gtk2AppLib::DIALOGS.question?(*Gtk2Password::Configuration::ARE_YOU_SURE) then
        @passwords.load # revert
        @modified = false
        @program.close
      end
    end

    def method_call(is,signal)
      self.method(signal).call(is) do |action|
        case action
        when :modified	then @modified ||= true
        when :save	then save
        when :close	then close
        end
      end
    end

    def build_gui
      Gtk2Password::Gui.new(@window) do |is,signal,*emits|
        $stderr.puts "#{is},#{signal}:\t#{emits}" if $trace
        method_call(is,signal)
      end
    end

    def self.get_account(account)
      if !account.nil? then
        account.strip!
        account = nil if account.length<1
      end
      return account
    end
    def get_account
      App.get_account( @gui[:account_comboboxentry].active_text )
    end

    def clicked(is)

      pwdlength = @gui[:password_spinbutton]
      account = get_account

      case is

      when @gui[:url_button]
        url = @gui[:url_entry].text.strip
        Gtk2AppLib.run(url) if url =~ Configuration::URL_PATTERN

      when @gui[:random_button]
        suggestion = ''
        pwdlength.value.to_i.times do
          suggestion += (Rnd::RND.random(94)+33).chr
        end
        @gui[:password_entry].text = suggestion

      when @gui[:alpha_button]
        suggestion = ''
        while suggestion.length <  pwdlength.value.to_i do
          chr = (Rnd::RND.random(75)+48).chr
          suggestion += chr if chr =~/\w/
        end
        @gui[:password_entry].text = suggestion

      when @gui[:numeric_button]
        suggestion = ''
        pwdlength.value.to_i.times do
          chr = (Rnd::RND.random(10)+48).chr
          suggestion += chr
        end
        @gui[:password_entry].text = suggestion

      when @gui[:letters_button]
        suggestion = ''
        while suggestion.length < pwdlength.value.to_i do
          chr = (Rnd::RND.random(58)+65).chr
          suggestion += chr if chr =~/[A-Z]/i
        end
        @gui[:password_entry].text = suggestion

      when @gui[:caps_button]
        suggestion = ''
        pwdlength.value.to_i.times do
          chr = (Rnd::RND.random(26)+65).chr
          suggestion += chr
        end
        @gui[:password_entry].text = suggestion

      when @gui[:delete_button]
        # MODIFIES!!!
        if account then
          i = @passwords.accounts.index(account)
          if i then
            @passwords.delete(account)
            @gui[:account_comboboxentry].remove_text(i)
            @@index = (@gui[:account_comboboxentry].active = (i > 0)? i - 1: 0)
            yield(:modified)
          end
        end

      when @gui[:update_button]
        # MODIFIES!!!
        if account then
          url = @gui[:url_entry].text.strip
          if url.length == 0 || url =~ Configuration::URL_PATTERN then
            yield(:modified)
            if !@passwords.include?(account) then
              @passwords.add(account) 
              @@index = i = @passwords.accounts.index(account)
              @gui[:account_comboboxentry].insert_text(i,account)
            end
            @passwords.url_of(account, url)
            @passwords.note_of(account, @gui[:note_entry].text.strip)
            @passwords.username_of(account, @gui[:username_entry].text.strip)
            password = @gui[:password_entry].text.strip
            @passwords.password_of(account, password) if !@passwords.verify?(account, password)
            Gtk2AppLib::DIALOGS.quick_message(*Configuration::UPDATED)
          else
            Gtk2AppLib::DIALOGS.quick_message(*Configuration::BAD_URL)
          end
        end

      when @gui[:datafile_button]
        if pwd1 = Gtk2Password.get_password(Passwords::PROMPT[:password]) then
          if pwd2 = Gtk2Password.get_password(Passwords::PROMPT[:again]) then
            while !(pwd1==pwd2) do
              pwd1 = Gtk2Password.get_password(Passwords::PROMPT[:retry])
              return if !pwd1
              pwd2 = Gtk2Password.get_password(Passwords::PROMPT[:again])
              return if !pwd2
            end
            @passwords.save!(pwd1)
            Gtk2Password.passwords_updated
          end
        end

      when @gui[:current_button]
        if account then
          PRIMARY.text = @passwords.password_of(account)
          CLIPBOARD.text = @passwords.username_of(account)
          Gtk2Password.clear_clipboard
        end

      when @gui[:previous_button]
        if account then
          PRIMARY.text = @passwords.previous_password_of(account)
          CLIPBOARD.text = @passwords.username_of(account)
          Gtk2Password.clear_clipboard
        end

      when @gui[:save_button]	then yield(:save)
      when @gui[:cancel_button]	then yield(:close)
      else $stderr.puts "What? #{is} in #{is.parent.class}."
      end

    end

    def _changed_clear
      @gui[:url_entry].text		= ''
      @gui[:note_entry].text		= ''
      @gui[:username_entry].text	= ''
    end

    def _changed_set(account)
      @gui[:url_entry].text		= @passwords.url_of(account)
      @gui[:note_entry].text		= @passwords.note_of(account)
      @gui[:username_entry].text	= @passwords.username_of(account)
      @gui[:password_entry].text	= @passwords.password_of(account)
    end

    def _changed(is,account)
      @gui[:password_entry].text	= ''
      (@passwords.include?(account))?  _changed_set(account) : _changed_clear
      @@index = is.active
      $stderr.puts "Index: #{@@index}" if $trace
    end

    def changed(is)
      if account = get_account then
        _changed(is,account)
      end
    end

    def self.toggled(pwd)
      pwd.visibility = !pwd.visibility?
    end
    def toggled(is)
      App.toggled(@gui[:password_entry])
    end

  end
end
