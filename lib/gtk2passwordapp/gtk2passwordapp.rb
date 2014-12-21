module Gtk2passwordapp
  using Rafini::Exception
  using Rafini::Array

  RND = SuperRandom.new
  H2Q = BaseConvert::FromTo.new(:hex, :qgraph)
  H2W = BaseConvert::FromTo.new(:hex, :word)

  def self.options=(opts)
    @@options=opts
  end

  def self.options
    @@options
  end

  def self.run(program)
    Gtk2PasswordApp.new(program)
  end

class DeleteDialog < Such::Dialog
  def initialize(parent)
    super([parent: parent], :delete_dialog)
    add_button(Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL)
    add_button(Gtk::Stock::OK, Gtk::ResponseType::OK)
    Such::Label.new child, :delete_label!
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

class BackupDialog < Such::FileChooserDialog
  def initialize(parent)
    super([parent: parent], :backup_dialog)
    set_action Gtk::FileChooser::Action::SAVE
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

class ErrorDialog < Such::MessageDialog
  def initialize(parent)
    super([parent: parent, flags: :modal, type: :error, buttons_type: :close], :error_dialog)
  end

  def runs
    set_secondary_text $!.message
    run
    destroy
  end
end

class Gtk2PasswordApp

  def initialize(program)
    @program = program
    @names = @combo = nil

    @blue  = Gdk::RGBA.parse(CONFIG[:Blue])
    @red   = Gdk::RGBA.parse(CONFIG[:Red])
    @black = Gdk::RGBA.parse(CONFIG[:Black])

    _ = CONFIG[:CustomDigits]
    @h2c = BaseConvert::FromTo.new(:hex, _.length)
    @h2c.to_digits = _

    if CONFIG[:SwitchClipboard]
      @clipboard = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
      @primary   = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
    else
      @primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
      @clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
    end

    @current, @previous  = [], []

    window = program.window
    @page = Such::Box.new window, :vbox!
    @accounts = Accounts.new(CONFIG[:PwdFile])
    password_page((@accounts.exist?)? :load : :init)
    window.show

    # Because accounts are editable from the main window,
    # minime's menu needs to be updated each time.
    destroy_menu_items
    program.mini.signal_connect('show'){generate_menu_items}
    program.mini.signal_connect('hide'){destroy_menu_items}
  end

  def copy2clipboard(pwd, user)
    @primary.text = pwd
    @clipboard.text = user
    GLib::Timeout.add_seconds(CONFIG[:ClipboardTimeout]) do
      @primary.request_text{  |_, text| @primary.text   = ''  if text == pwd  }
      @clipboard.request_text{|_, text| @clipboard.text = ''  if text == user }
      false
    end
  end

  def color_code(selected)
    @current.unshift selected; @current.uniq!
    if @current.length > CONFIG[:Recent]
      popped = @current.pop
      popped.override_color :normal, @black
    end
    selected.override_color :normal, @blue
  end

  def generate_menu_items
    now   = Time.now.to_i
    @accounts.names.sort{|a,b|a.upcase<=>b.upcase}.each do |name|
      account = @accounts.get name
      pwd, user, updated = account.password, account.username, account.updated
      too_old = ((now - updated) > CONFIG[:TooOld])
      selected = Such::MenuItem.new([name], 'activate') do
        color_code selected unless too_old
        @combo.set_active @names.index name if @combo
        copy2clipboard pwd, user
      end
      if too_old
        selected.override_color :normal, @red
      elsif @previous.include? name
        @current[@previous.index(name)] = selected
        selected.override_color :normal, @blue
      end
      @program.mini_menu.append selected
      selected.show
    end
    @current.delete_if{|a|a.nil?}
    @previous.clear
  end

  def destroy_menu_items
    @current.each{|item| @previous.push item.label}
    @current.clear
    @program.mini_menu.each{|item|item.destroy}
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
        @accounts.save pwd1
      else
        if pwd1=~/^\d+\-[\dabcdef]+$/ # then we probably have a shared secret...
          if File.exist? CONFIG[:SharedSecretFile] # and looks like we really do...
            pwd0 = File.read(CONFIG[:SharedSecretFile]).strip
            pwd = Helpema::SSSS.combine(pwd0, pwd1)
            pwd1 = pwd unless pwd=='' # but maybe not.
          end
        end
        @accounts.load pwd1
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
        ErrorDialog.new(@program.window).runs
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

    password_entry1.signal_connect('activate') do
      if password_entry2
        password_entry2.grab_focus
      else
        action.b_Button.clicked
      end
    end
    if  password_entry2
      password_entry2.signal_connect('activate') do
        action.b_Button.clicked
      end
    end

    @page.show_all
  end

  def create_combo
    combo = Such::PromptedCombo.new @page, :hbox!
    combo.prompt_Label.text = CONFIG[:Name]
    @combo= combo.prompted_ComboBoxText
    @names = @accounts.names.sort{|a,b|a.upcase<=>b.upcase}
    @names.each{|name|@combo.append_text name}
    @combo.set_active @names.index(@account.name)
    @combo.signal_connect('destroy'){@names = @combo = nil}
  end

  def create_entries
    entries = {}
    CONFIG[:FIELDS].each do |field, text|
      entry = Such::PromptedLabel.new @page, :hbox!
      entry.prompt_Label.text = text
      entry.prompted_Label.text = @account.method(field).call
      entry.prompted_Label.set_alignment(*CONFIG[:FIELD_ALIGNMENT])
      entries[field] = entry
    end
    return entries
  end

  def any_name
    names = @accounts.names
    if name = ARGV.shift
      unless names.include? name
        like = Regexp.new name
        name = names.which{|nm|nm=~like}
      end
    end
    name = names.sample unless name
    return name
  end

  def view_page
    if @accounts.data.length == 0
      edit_page(:add)
      return
    end
    @account ||= @accounts.get any_name

    clear_page

    Such::Label.new @page, :view_label!
    create_combo
    entries = create_entries

    label, hidden = entries[:password].prompted_Label, CONFIG[:HiddenPwd]
    label.text = hidden

    @combo.signal_connect('changed') do
      @account = @accounts.get @combo.active_text
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
    name.prompted_Label.set_alignment(*CONFIG[:FIELD_ALIGNMENT])

    entries = {}
    CONFIG[:FIELDS].each do |field, text|
      entry = Such::PromptedEntry.new @page, :hbox!
      entry.prompt_Label.text = text
      entry.prompted_Entry.text = @account.method(field).call if mode==:edit
      entries[field] = entry
    end

    # cb and sb will be a CheckButton and SpinButton respectively.
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
    pwd.set_visibility false
    pwd.signal_connect('focus-in-event' ){pwd.set_visibility true}
    pwd.signal_connect('focus-out-event'){pwd.set_visibility false}

    generators = Such::AbcButtons.new(@page, :hbox!) do |button,*e,s|
      hex = RND.hexadecimal
      case button
      when generators.a_Button
        pwd.text = truncate.call H2Q.convert hex
      when generators.b_Button
        pwd.text = truncate.call H2W.convert hex
      when generators.c_Button
        pwd.text = truncate.call @h2c.convert hex
      end
    end
    generators.labels :Random, :AlphaNumeric, :Custom

    cb = Such::CheckButton.new(generators, :pwd_size_check!, 'toggled') do
      pwd.text = (cb.active?) ? truncate.call(password) : password
    end
    sb = Such::SpinButton.new(generators,  :pwd_size_spin!, 'value-changed') do
      pwd.text = truncate.call password  if cb.active?
    end

    action = Such::AbcButtons.new(@page, :hbox!) do |button, *_|
      case button
      when action.a_Button # Cancel
        if edited
          @accounts.load
          @account = previous ? @accounts.get(previous) : nil
        end
        view_page
      when action.b_Button # Delete
        dialog = DeleteDialog.new(@program.window)
        dialog.set_title @account.name
        if dialog.runs
          @accounts.delete @account.name
          @accounts.save
          @account = nil
          view_page
        end
      when action.c_Button # Save
        edited = true
        begin
          if mode==:add
            @account = @accounts.add(name.prompted_Entry.text.strip)
            name.prompted_Label.text = @account.name
            name.prompted_Entry.hide
            name.prompted_Label.show
            name.prompt_Label.override_color :normal, @blue
            mode = :edit
          end
          errors = false
          entries.each do |field, entry|
            begin
              @account.method("#{field}=".to_sym).call(entry.prompted_Entry.text.strip)
              entry.prompt_Label.override_color :normal, @blue
            rescue RuntimeError
              $!.puts
              errors ||= true
              entry.prompt_Label.override_color :normal, @red
            end
          end
          unless errors
            @accounts.save
            view_page
          end
        rescue RuntimeError
          $!.puts
          name.prompt_Label.override_color :normal, @red
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
