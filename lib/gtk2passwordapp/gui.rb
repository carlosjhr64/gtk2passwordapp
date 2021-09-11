class Gtk2PasswordApp
  def initialize(stage, toolbar, options)
    @primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)  
    @clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
    @accounts  = Accounts.new(CONFIG[:PwdFile])
    @toolbox   = Such::Box.new toolbar, :toolbox!
    @pages     = Such::Box.new stage, :pages!
    @recent = []
    @reset = @on_main_page = false
    @red,@green,@blue,@white =
      [:Red,:Green,:Blue,:White].map{Gdk::RGBA.parse(CONFIG[_1])}
    @tools = @password_page = @add_page = @edit_page = @main_page = @menu = nil
    build_password_page
    build_logo_menu
  end

  def build_logo_menu
    Gtk3App.logo_press_event do |button|
      next unless @on_main_page
      case button
      when 1
        popup_accounts_menu unless @accounts.data.empty?
      when 2
        reset_password
      when 3
        # Gets captured by Gtk3App's main menu
      end
    end
  end

  def reset_password
    ursure = Gtk3App::YesNoDialog.new :reset_ursure!
    Gtk3App.transient ursure
    if ursure.ok?
      @reset = true
      hide_main_page
      @password_page.show
    end
  end

  def popup_accounts_menu
    @menu = Such::Menu.new :main_menu!
    @menu.override_background_color(:normal, @white)
    @recent.each do |name| add_menu_item(name, @green) end
    @accounts.data.keys.sort{|a,b|a.upcase<=>b.upcase}.each do |name|
      add_menu_item(name)
    end
    @menu.show_all
    @menu.popup_at_pointer
  end

  def add_menu_item(name, color=nil)
    menu_item = Such::MenuItem.new [label:name], :main_menu_item, 'activate' do
      selected_account(name)
    end
    account = @accounts.get name
    unless color
      color = (Time.now.to_i - account.updated > CONFIG[:TooOld])? @red : @blue
    end
    menu_item.override_color :normal, color
    @menu.append menu_item
  end

  def selected_account(name)
    @recent.unshift name; @recent.uniq!; @recent.pop if @recent.length>3
    account = @accounts.get name
    setup_main_page account
    setup_edit_page account
    copy2clipboard(account.password, account.username)
  end

  def copy2clipboard(pwd, user)
    @primary.text, @clipboard.text = pwd, user
    GLib::Timeout.add_seconds(CONFIG[:ClipboardTimeout]) do
      @primary.text = '' if @primary.wait_for_text == pwd
      @clipboard.text = '' if @clipboard.wait_for_text == user
      false
    end
  end

  def view_row(page, label)
    row = Such::Box.new page, :field_row!
    Such::Label.new(row, label, :field_label)
    Such::Label.new(row, :field_view!)
  end

  def field_row(page, label, entry=:field_entry!, &block)
    row = Such::Box.new page, :field_row!
    Such::Label.new(row, label, :field_label)
    Such::Entry.new(row, entry, ((block)? 'activate' : ''), &block)
  end

  def show_main_page
    @on_main_page = true
    @main_page.show_all
    @toolbox.show_all
  end

  def hide_main_page
    @on_main_page = false
    @main_page.hide
    @toolbox.hide
  end

  def bootstrap_setups
    names = @accounts.data.keys
    account = (names.empty?)? nil : @accounts.get(names[rand(names.length)])
    setup_edit_page(account) if account
    setup_main_page(account)
  end

  def rehash(pwd)
    pwd += CONFIG[:Salt] if pwd.length < CONFIG[:LongPwd]
    pwd = Digest::SHA256.hexdigest(pwd).upcase
    H2Q.convert pwd
  end

  def build_password_page
    @password_page = Such::Box.new @pages, :page!
    Such::Label.new @password_page, :PASSWORD_PAGE_LABEL, :page_label
    error_label,previous = nil,'' # updates below
    password_entry = field_row(@password_page, :PASSWORD, :password_entry!) do
      pwd = password_entry.text.strip
      password_entry.text = ''
      raise CONFIG[:TooShort] if pwd.length < CONFIG[:MinPwdLen]
      if not @reset and @accounts.exist?
        @accounts.load rehash pwd
      else
        raise CONFIG[:Confirm] unless pwd==previous
        @accounts.save rehash pwd
        @reset = false
      end
      @password_page.hide
      build_add_page  unless @add_page
      build_edit_page unless @edit_page
      build_main_page unless @main_page
      build_tools     unless @tools
      bootstrap_setups
      show_main_page
    rescue
      error_label.text = $!.message
      previous = pwd
    end
    error_label = Such::Label.new @password_page, :error_label!
  end

  def build_add_page
    @add_page = Such::Box.new @pages, :page!
    Such::Label.new @add_page, :ADD_PAGE_LABEL, :page_label
    error_label = nil # updates below
    add_account_entry = field_row(@add_page, :NAME) do
      name = add_account_entry.text.strip
      @accounts.add name
      @accounts.save
      account = @accounts.get name
      setup_edit_page(account)
      setup_main_page(account)
      @add_page.hide
      add_account_entry.text = ''
      @edit_page.show_all
    rescue
      error_label.text = $!.message
    end
    Such::Button.new @add_page, :CANCEL, :tool_button do
      @add_page.hide
      add_account_entry.text = ''
      show_main_page
    end
    error_label = Such::Label.new @add_page, :error_label!
  end

  def visibility_toggleling(entry)
    entry.signal_connect('enter-notify-event') do
      entry.set_visibility true unless entry.has_focus?
    end
    entry.signal_connect('leave-notify-event') do
      entry.set_visibility false unless entry.has_focus?
    end
    entry.signal_connect('focus-in-event') do
      entry.set_visibility true
    end
    entry.signal_connect('focus-out-event') do
      entry.set_visibility false
    end
  end

  def show_toggleling(label)
    label.signal_connect('button-press-event') do |_,e|
      if e.button==1 and not (pwd=label.text).empty?
        case pwd
        when CONFIG[:HiddenPwd]
          label.text = @accounts.get(@name.text).password
        when TOTPx
          label.text = TOTP.passwords(label.text)[1].to_s
        else
          label.text = CONFIG[:HiddenPwd]
        end
      end
    end
  end

  def build_edit_page
    @edit_page = Such::Box.new @pages, :page!
    Such::Label.new @edit_page, :EDIT_PAGE_LABEL, :page_label

    @edit_name     = view_row  @edit_page, :NAME
    @edit_url      = field_row @edit_page, :URL
    @edit_note     = field_row @edit_page, :NOTE
    @edit_username = field_row @edit_page, :USERNAME
    @edit_password = field_row @edit_page, :PASSWORD, :password_entry!

    visibility_toggleling @edit_password

    generator = Such::Box.new @edit_page, :toolbox!
    pwdlen=rndpwd=nil
    Such::Button.new generator, :RAND, :tool_button do
      rndpwd = H2Q.convert RND.hexadecimal
      @edit_password.text = rndpwd[0...pwdlen.value]
    end
    pwdlen = Such::SpinButton.new generator, :pwdlen!, 'value-changed' do
      @edit_password.text = rndpwd[0...pwdlen.value] if rndpwd
    end

    toolbox     = Such::Box.new @edit_page,   :toolbox!
    error_label = Such::Label.new @edit_page, :error_label!

    Such::Button.new toolbox, :SAVE, :tool_button do
      account          = @accounts.get @edit_name.text.strip
      account.url      = @edit_url.text.strip
      account.note     = @edit_note.text.strip
      account.username = @edit_username.text.strip
      account.password = @edit_password.text.strip
      @accounts.save
      rndpwd = nil
      @edit_page.hide
      setup_main_page(account)
      show_main_page
    rescue
      error_label.text = $!.message
    end
    Such::Button.new toolbox, :CANCEL, :tool_button do
      account = @accounts.get @edit_name.text
      rndpwd = nil
      @edit_page.hide
      setup_edit_page(account) # restore values
      show_main_page
    end
    Such::Button.new toolbox, :DELETE, :tool_button do
      ursure = Gtk3App::YesNoDialog.new :delete_ursure!
      Gtk3App.transient ursure
      if ursure.ok?
        @recent.delete @edit_name.text
        @accounts.delete @edit_name.text
        @accounts.save
        rndpwd = nil
        @edit_page.hide
        bootstrap_setups
        show_main_page
      end
    end
  end

  def setup_edit_page(account)
    @edit_name.text     = account.name
    @edit_url.text      = account.url
    @edit_note.text     = account.note
    @edit_username.text = account.username
    @edit_password.text = account.password
  end

  def build_main_page
    @main_page = Such::Box.new @pages, :page!
    Such::Label.new @main_page, :MAIN_PAGE_LABEL, :page_label

    @name     = view_row @main_page, :NAME
    @url      = view_row @main_page, :URL
    @note     = view_row @main_page, :NOTE
    @username = view_row @main_page, :USERNAME
    @password = view_row @main_page, :PASSWORD

    show_toggleling @password
  end

  def setup_main_page(account)
    @name.text     = account&.name     || ''
    @url.text      = account&.url      || ''
    @note.text     = account&.note     || ''
    @username.text = account&.username || ''
    @password.text =(account&.password&.>'')? CONFIG[:HiddenPwd] : ''
  end

  def build_tools
    @tools = true
    Such::Button.new @toolbox, :ADD, :tool_button do
      hide_main_page
      @add_page.show_all
    end
    Such::Button.new @toolbox, :EDIT, :tool_button do
      unless (name=@name.text).empty?
        hide_main_page
        @edit_page.show_all
      end
    end
    Such::Button.new @toolbox, :GO, :tool_button do
      unless (name=@name.text).empty?
        url = @accounts.get(name).url
        system(Gtk3App::CONFIG[:Open], url) unless url.empty?
      end
    end
    Such::Button.new @toolbox, :CURRENT, :tool_button do
      unless (name=@name.text).empty?
        account = @accounts.get name
        copy2clipboard(account.password, account.username)
      end
    end
    Such::Button.new @toolbox, :PREVIOUS, :tool_button do
      unless (name=@name.text).empty?
        account = @accounts.get name
        copy2clipboard(account.previous, account.password)
      end
    end
  end

  def self.run = Gtk3App.run(klass:Gtk2PasswordApp)
end
