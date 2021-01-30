class Gtk2PasswordApp
  def initialize(stage, toolbar, options)
    @primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)  
    @clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
    @accounts  = Accounts.new(CONFIG[:PwdFile])
    @toolbox   = Such::Box.new toolbar, :toolbox!
    @pages     = Such::Box.new stage, :pages!
    @password_page = @edit_page = nil
    build_password_page
    Gtk3App.logo_press_event do #|button|
      unless @accounts.data.empty?
        menu = Such::Menu.new :main_menu!
        @accounts.data.keys.sort{|a,b|a.upcase<=>b.upcase}.each do |name|
          menu_item = Such::MenuItem.new [label:name], :main_menu_item, 'activate' do
            account = @accounts.get name
            setup_main_page account
            setup_edit_page account
            @primary.text = pwd = account.password
            @clipboard.text = account.username
            GLib::Timeout.add_seconds(CONFIG[:ClipboardTimeout]) do
              @primary.text = '' if @primary.wait_for_text == pwd
              false
            end
          end
          menu.append menu_item
        end
        menu.show_all
        menu.popup_at_pointer
      end
    end
  end

  def rehash(pwd)
    pwd += CONFIG[:Salt] if pwd.length < CONFIG[:LongPwd]
    pwd = Digest::SHA256.hexdigest(pwd).upcase
    h2q = BaseConvert::FromTo.new(base: 16, digits: '0123456789ABCDEF', to_base:91, to_digits: :qgraph)
    h2q.convert pwd
  end

  def view_row(page, label)
    row = Such::Box.new page, :field_row!
    Such::Label.new(row, label, :field_label)
    Such::Label.new(row, :field_label!)
  end

  def field_row(page, label, entry=:field_entry!, &block)
    row = Such::Box.new page, :field_row!
    Such::Label.new(row, label, :field_label)
    Such::Entry.new(row, entry, ((block)? 'activate' : ''), &block)
  end

  def build_password_page
    @password_page = Such::Box.new @pages, :page!
    # TODO: :PASSWORD_PAGE_LABEL ?
    error_label,previous = nil,'' # updates below
    password_entry = field_row(@password_page, :PASSWORD, :password_entry!) do
      pwd = password_entry.text.strip
      raise 'Password too short!' if pwd.length < CONFIG[:MinPwdLen]
      if @accounts.exist?
        @accounts.load rehash pwd
      else
        raise CONFIG[:Confirm] unless pwd==previous
        @accounts.save rehash pwd
      end
      @password_page.hide
      build_add_page  unless @add_page
      build_edit_page unless @edit_page
      build_main_page unless @main_page
      if @accounts.data.empty?
        @add_page.show_all
      else
        names = @accounts.data.keys
        account = @accounts.get names[rand(names.length)]
        setup_main_page(account)
        @main_page.show_all
      end
    rescue
      error_label.text = $!.message
      password_entry.text = ''
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
      account = @accounts.get name
      setup_edit_page(account)
      @add_page.hide
      @edit_page.show_all
    rescue
      error_label.text = $!.message
    end
    error_label = Such::Label.new @add_page, :error_label!
  end

  def build_edit_page
    @edit_page = Such::Box.new @pages, :page!
    Such::Label.new @edit_page, :EDIT_PAGE_LABEL, :page_label

    @edit_name     = view_row  @edit_page, :NAME
    @edit_url      = field_row @edit_page, :URL
    @edit_note     = field_row @edit_page, :NOTE
    @edit_username = field_row @edit_page, :USERNAME
    @edit_password = field_row @edit_page, :PASSWORD, :password_entry!

    error_label = nil # updated below
    Such::Button.new @edit_page, :submit_button! do
      account          = @accounts.get @edit_name.text.strip
      account.url      = @edit_url.text.strip
      account.note     = @edit_note.text.strip
      account.username = @edit_username.text.strip
      account.password = @edit_password.text.strip
      @accounts.save
      @edit_page.hide
      setup_main_page(account)
      @main_page.show_all
    rescue
      error_label.text = $!.message
    end
    error_label = Such::Label.new @edit_page, :error_label!
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
  end

  def setup_main_page(account)
    @name.text     = account.name
    @url.text      = account.url
    @note.text     = account.note
    @username.text = account.username
    @password.text = account.password
  end

  def self.run = Gtk3App.run(klass:Gtk2PasswordApp)
end
