module Gtk2passwordapp
  using Rafini::Exception

  ACCOUNTS = Accounts.new(CONFIG[:PwdFile])

  if CONFIG[:SwitchClipboard]
    CLIPBOARD = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
    PRIMARY   = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
  else
    PRIMARY   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
    CLIPBOARD = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
  end

  RND = SuperRandom.new
  H2Q = BaseConvert::FromTo.new(:hex, :qgraph)
  H2W = BaseConvert::FromTo.new(:hex, :word)

  _ = CONFIG[:CustomDigits]
  H2C = BaseConvert::FromTo.new(:hex, _.length)
  H2C.to_digits = _

  def self.options=(opts)
    @@options=opts
  end

  def self.options
    @@options
  end

  def self.run(program)
    Gtk2PasswordApp.new(program)
  end

class Dialog < Such::Dialog
  def initialize(*par)
    super
    add_button(Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL)
    add_button(Gtk::Stock::OK, Gtk::ResponseType::OK)
  end

  def runs
    show_all
    response = run
    response = yield(response)
    destroy
    return response
  end
end

class Gtk2PasswordApp
  def initialize(program)
    @program = program
    window = program.window
    @page = Such::Box.new window, :vbox!
    password_page((ACCOUNTS.exist?)? :load : :init)
    window.show
  end

  def copy2clipboard(pwd, user)
    PRIMARY.text = pwd
    CLIPBOARD.text = user
    GLib::Timeout.add_seconds(CONFIG[:ClipboardTimeout]) do
      PRIMARY.request_text{  |_, text| PRIMARY.text   = ''  if text == pwd  }
      CLIPBOARD.request_text{|_, text| CLIPBOARD.text = ''  if text == user }
    end
  end

  def clear_page
    @page.each{|w|w.destroy}
  end

  # mode can be :init, :load, or :reset
  def password_page(mode)
    clear_page

    password_label  = Such::Label.new @page, :password_label!
    password_entry1 = Such::Entry.new @page, :password_entry!
    password_entry2 = (mode==:load)? nil : Such::Entry.new(@page, :password_entry!)

    action = Such::AbButtons.new(@page, :hbox!) do |button, *_|
      case button
      when action.a_Button
        (mode==:reset)? view_page : @program.quit!
      when action.b_Button
        begin
          pwd1 = password_entry1.text.strip
          if password_entry2
            raise 'Passwords did not match' unless password_entry2.text.strip==pwd1
            ACCOUNTS.save pwd1
          else
            ACCOUNTS.load pwd1
          end
          unless mode==:reset
            @program.app_menu.append_menu_item(:reset!){password_page(:reset)}
          end
          view_page
        rescue StandardError
          $!.puts
          password_entry1.text = ''
          password_entry2.text = '' if password_entry2
          password_label.text  = CONFIG[:ReTry]
        end
      end
    end
    action.labels :Cancel, :Go

    @page.show_all
  end

  def create_combo
    combo = Such::PromptedCombo.new @page, :hbox!
    combo.prompt_Label.text = CONFIG[:Name]
    names = ACCOUNTS.names.sort{|a,b|a.upcase<=>b.upcase}
    names.each do |name|
      combo.prompted_ComboBoxText.append_text name
    end
    combo.prompted_ComboBoxText.set_active names.index(@account.name)
    return combo
  end

  def create_entries
    entries = {}
    CONFIG[:FIELDS].each do |field, text|
      entry = Such::PromptedLabel.new @page, :hbox!
      entry.prompt_Label.text = text
      entry.prompted_Label.text = @account.method(field).call
      entries[field] = entry
    end
    return entries
  end

  def view_page
    if ACCOUNTS.data.length == 0
      edit_page(:add)
      return
    end

    clear_page
    @account ||= ACCOUNTS.get ACCOUNTS.names.sample

    Such::Label.new @page, :view_label!
    combo = create_combo
    entries = create_entries

    label, hidden = entries[:password].prompted_Label, CONFIG[:HiddenPwd]
    label.text = hidden

    combo.prompted_ComboBoxText.signal_connect('changed') do
      @account = ACCOUNTS.get combo.prompted_ComboBoxText.active_text
      CONFIG[:FIELDS].each do |field, _|
        entries[field].prompted_Label.text = @account.method(field).call
      end
      label.text = hidden
    end

    clip_box = Such::AbcButtons.new(@page, :hbox!) do |button, *_|
      case button
      when clip_box.a_Button # Current
        copy2clipboard @account.password, @account.username
      when clip_box.b_Button # Previous
        copy2clipboard @account.previous, @account.password
      when clip_box.c_Button # Show
        label.text == hidden ?
        label.text = @account.password :
        label.text = hidden
      end
    end
    clip_box.labels :Current, :Previous, :Show

    edit_box = Such::AbcButtons.new(@page, :hbox!) do |button, *_|
      case button
      when edit_box.a_Button then edit_page
      when edit_box.b_Button then edit_page(:add)
      when edit_box.c_Button
        system("#{Gtk3App::CONFIG[:Open]} '#{@account.url}'") if @account.url.length > 0
      end
    end
    edit_box.labels :Edit, :Add, :Goto

    @page.show_all
  end

  def edit_page(mode=:edit)
    clear_page

    edited = false
    previous = @account ? @account.name : nil
    name = nil

    case mode
    when :add
      Such::Label.new @page, :add_label!
      name = Such::PromptedEntryLabel.new @page, :hbox!
      name.prompt_Label.text = CONFIG[:Name]
    when :edit
      Such::Label.new @page, :edit_label!
      name = Such::PromptedLabel.new @page, :hbox!
      name.prompt_Label.text = CONFIG[:Name]
      name.prompted_Label.text = @account.name
    end

    entries = {}
    CONFIG[:FIELDS].each do |field, text|
      entry = Such::PromptedEntry.new @page, :hbox!
      entry.prompt_Label.text = text
      entry.prompted_Entry.text = @account.method(field).call if mode==:edit
      entries[field] = entry
    end

    cb = sb = nil
    password = @account.password
    truncate = Proc.new do |p|
      password = p
      if cb.active?
        n = sb.value.to_i
        p = p[-n..-1] if p.length > n
      end
      p
    end

    pwd = entries[:password].prompted_Entry
    generators = Such::AbcButtons.new(@page, :hbox!) do |button,*e,s|
      hex = RND.hexadecimal
      case button
      when generators.a_Button
        pwd.text = truncate.call H2Q.convert hex
      when generators.b_Button
        pwd.text = truncate.call H2W.convert hex
      when generators.c_Button
        pwd.text = truncate.call H2C.convert hex
      end
    end
    generators.labels :Random, :AlphaNumeric, :Custom

    cb = Such::CheckButton.new(generators, :pwd_size_check!, 'toggled') do
      pwd.text = (cb.active?) ? truncate.call(password) : password
    end
    sb = Such::SpinButton.new(generators,  :pwd_size_spin!, 'value-changed') do
      pwd.text = truncate.call password  if cb.active?
    end

    good, bad = Gdk::RGBA.parse(CONFIG[:GoodColor]),  Gdk::RGBA.parse(CONFIG[:BadColor])
    action = Such::AbcButtons.new(@page, :hbox!) do |button, *_|
      case button
      when action.a_Button # Cancel
        if edited
          ACCOUNTS.load
          @account = previous ? ACCOUNTS.get(previous) : nil
        end
        view_page
      when action.b_Button # Delete
        dialog = Dialog.new [parent: @program.window], :delete_dialog!
        Such::Label.new dialog.child, [CONFIG[:Delete?]]
        if dialog.runs{|response| (response==Gtk::ResponseType::OK)}
          ACCOUNTS.delete @account.name
          ACCOUNTS.save
          @account = nil
          view_page
        end
      when action.c_Button # Save
        edited = true
        begin
          if mode==:add
            @account = ACCOUNTS.add(name.prompted_Entry.text.strip)
            name.prompted_Label.text = @account.name
            name.prompted_Entry.hide
            name.prompted_Label.show
            name.prompt_Label.override_color :normal, good
            mode = :edit
          end
          errors = 0
          entries.each do |field, entry|
            begin
              @account.method("#{field}=".to_sym).call(entry.prompted_Entry.text.strip)
              entry.prompt_Label.override_color :normal, good
            rescue RuntimeError
              $!.puts
              errors += 1
              entry.prompt_Label.override_color :normal, bad
            end
          end
          if errors == 0
            ACCOUNTS.save
            view_page
          end
        rescue RuntimeError
          $!.puts
          name.prompt_Label.override_color :normal, bad
        end
      end
    end
    action.labels :Cancel, :Delete, :Save

    @page.show_all
    if mode==:add
      name.prompted_Label.hide
      action.b_Button.hide
    end
  end

end

end
