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
    value = false
    if run == Gtk::ResponseType::OK
      value = true
    end
    destroy
    return value
  end
end

class BackupDialog < Gtk::FileChooserDialog
  def initialize(parent)
    super title: CONFIG[:thing][:BACKUP].first, parent: parent, action: Gtk::FileChooser::Action::SAVE
    add_button(Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL)
    add_button(Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT)
    if CONFIG[:BackupFile]
      set_filename CONFIG[:BackupFile]
      set_current_name File.basename CONFIG[:BackupFile]
    end
  end

  def runs
    show_all
    value = nil
    if run == Gtk::ResponseType::ACCEPT
     value = filename
    end
    destroy
    return value
  end
end

class Gtk2PasswordApp

  def initialize(program)
    @program = program

    window = program.window
    @page = Such::Box.new window, :vbox!
    password_page((ACCOUNTS.exist?)? :load : :init)
    window.show

    # Because accounts are editable from the main window,
    # minime's menu needs to be updated each time.
    mini = program.mini
    mini.signal_connect('show'){generate_menu_items}
    mini.signal_connect('hide'){destroy_menu_items}
  end

  def copy2clipboard(pwd, user)
    PRIMARY.text = pwd
    CLIPBOARD.text = user
    GLib::Timeout.add_seconds(CONFIG[:ClipboardTimeout]) do
      PRIMARY.request_text{  |_, text| PRIMARY.text   = ''  if text == pwd  }
      CLIPBOARD.request_text{|_, text| CLIPBOARD.text = ''  if text == user }
    end
  end

  def generate_menu_items
    mini_menu = @program.mini_menu
    item = Gtk::SeparatorMenuItem.new
    mini_menu.append item
    item.show
    names = ACCOUNTS.names.sort{|a,b|a.upcase<=>b.upcase}
    names.each do |name|
      account = ACCOUNTS.get name
      pwd, user = account.password, account.username
      item = Such::MenuItem.new([name], 'activate'){copy2clipboard(pwd, user)}
      mini_menu.append item
      item.show
    end
  end

  def destroy_menu_items
    sep = false
    @program.mini_menu.each do |item|
      sep = true if item.class == Gtk::SeparatorMenuItem
      item.destroy if sep
    end
  end

  def clear_page
    @page.each{|w|w.destroy}
  end

  def process_pwd_entries(entry1, entry2)
    begin
      pwd1 = entry1.text.strip
      if pwd1 == '' and pwd = Helpema::ZBar.qrcode(CONFIG[:QrcTimeOut])
        pwd1 = pwd
      end
      raise 'No password given.' if pwd1 == ''
      if entry2
        raise 'Passwords did not match' unless entry2.text.strip==pwd1
        ACCOUNTS.save pwd1
      else
        if pwd1=~/^\d+\-[\dabcdef]+$/ # then we probably have a shared secret...
          if File.exist? CONFIG[:SharedSecretFile] # and looks like we really do...
            pwd0 = File.read(CONFIG[:SharedSecretFile]).strip
            pwd = Helpema::SSSS.combine(pwd0, pwd1)
            pwd1 = pwd unless pwd=='' # but maybe not.
          end
        end
        ACCOUNTS.load pwd1
      end
      true
    rescue StandardError
      $!.puts
      entry1.text = ''
      entry2.text = '' if entry2
      false
    end
  end

  def backup
    if filename = BackupDialog.new(@program.window).runs
      begin
        FileUtils.cp CONFIG[:PwdFile], filename
      rescue
        $!.puts
        md = Such::MessageDialog.new :BACKUP_ERROR
        md.set_secondary_text $!.message
        md.run; md.destroy
      end
    end
  end

  # mode can be :init, :load, or :reset
  def password_page(mode)
    clear_page

    password_label  = Such::Label.new @page, :password_label!
    password_entry1 = Such::Entry.new @page, :password_entry!
    password_entry2 = (mode==:load)? nil : Such::Entry.new(@page, :password_entry!)

    action = Such::AbButtons.new(@page, :hbox!) do |button, *_|
      case button
      when action.a_Button # Cancel
        (mode==:reset)? view_page : @program.quit!
      when action.b_Button # Go
        if process_pwd_entries password_entry1, password_entry2
          unless mode==:reset
            @program.app_menu.append_menu_item(:reset!){password_page(:reset)}
            @program.app_menu.append_menu_item(:backup!){backup}
          end
          view_page
        else
          password_label.text = CONFIG[:ReTry]
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
    password = @account ? @account.password : ''
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
        if dialog.runs
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
