require 'gtk2passwordapp/passwords_data'
require 'find'

class Gtk2PasswordApp
  include Configuration

  ABOUT	= {
	'authors'	=> ['carlosjhr64@gmail.com'],
	'comments'	=> "Ruby-Gtk2 Password Manager.",
	'version'	=> $version,
	'website'	=> 'http://ruby-gnome-apps.blogspot.com/search/label/Passwords',
	'website-label'	=> 'Ruby Gnome Password Manager',
	'license'	=> 'GPL',
	'copyright'	=> '$Date: 2009/02/28 00:30:16 $'.gsub(/\s*\$\s*/,''),
	'logo'		=> Gdk::Pixbuf.new(GEM_ROOT_DIR+'/gifs/logo.gif'),
  }

  BUTTONS = [[ :username, :current, :url, ],[ :note, :edit, :quit, ],]

  EDITOR_LABELS = [
	:account,
 	:url,
 	:note,
 	:username,
 	:password,
	]


  EDITOR_BUTTONS = [
	[ :random, :alphanum, :num, :alpha, :caps, ],
	[ :visibility, :current, :previous, :cancel, :save, :update, ],
	[ :delete, :cpwd, :cpph ],
	]

  TEXT = {
	# Labels
	:account	=> 'Account',
	:note		=> 'Note',
	:password	=> 'New',
	# Buttons
	:username	=> 'Username',
	:current	=> 'Current',
	:url		=> 'Url',
	:note		=> 'Note',
	:edit		=> 'Edit',
	:update		=> 'Update',
	:visibility	=> 'Visible',
	:alphanum	=> 'Alpha-Numeric',
	:num		=> 'Numeric',
	:alpha		=> 'Letters',
	:caps		=> 'All-Caps',
	:random		=> 'Random',
	:previous	=> 'Previous',
	:quit		=> 'Quit',
	:cancel		=> 'Cancel',
	:save		=> 'Save',
	:cpwd		=> 'Data File Password',
	:cpph		=> 'Data File Passphrase',
	:delete		=> 'Delete Account',
  }

  def quit_windows
    if @editing
      @editing.hide
      @editing.destroy
      @editing = nil
    end
    if @window
      @window.hide
      @window.destroy
      @window = nil
    end
  end

  def quick_message(message, window, title='Note', font=FONT)
    # Create the dialog
    dialog = Gtk::Dialog.new(
        title,
        window, Gtk::Dialog::DESTROY_WITH_PARENT,
        [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])

    # Ensure that the dialog box is destroyed when the user responds.
    dialog.signal_connect('response') { dialog.destroy }

    # Add the message in a label, and show everything we've added to the dialog.
    label = Gtk::Label.new(message)
    label.wrap = true
    label.modify_font(font) if font
    dialog.vbox.add(label)
    dialog.show_all
  end

  def get_salt(title='Short Password')
    dialog = Gtk::Dialog.new(
        title,
        nil, nil,
        [ Gtk::Stock::QUIT,  0 ],
        [ Gtk::Stock::OK,  1 ])

    label = Gtk::Label.new(title)
    label.justify = Gtk::JUSTIFY_LEFT
    label.wrap = true
    label.modify_font(FONT)
    dialog.vbox.add(label)
    entry = Gtk::Entry.new
    entry.visibility = false
    entry.modify_font(FONT)
    dialog.vbox.add(entry)
    dialog.show_all

    entry.signal_connect('activate'){
      dialog.response(1)
    }

    ret = nil
    dialog.run {|response|
      ret = entry.text.strip if response == 1
    }
    dialog.destroy

    return ret
  end

  def _create_passphrase(pfile)
    passphrase = ''

    56.times do
      passphrase += (rand(94)+33).chr
    end
    File.open(pfile,'w'){|fh| fh.write passphrase }
    File.chmod(0600, pfile)

    return passphrase
  end

  def get_passphrase(mv=false)
    passphrase = ''

    pfile = USER_CONF_DIR+'/passphrase.txt'
    if mv then
      File.rename(pfile, pfile+'.bak') if File.exist?(pfile)
      passphrase = _create_passphrase(pfile)
    else
      if File.exist?(pfile) then
        File.open(pfile,'r'){|fh| passphrase = fh.read }
      else
        passphrase = _create_passphrase(pfile)
      end
    end

    return passphrase
  end

  def has_datafile?
    Find.find(USER_CONF_DIR){|fn|
      Find.prune if !(fn==USER_CONF_DIR) &&  File.directory?(fn)
      if fn =~/[0123456789abcdef]{32}\.dat$/ then
        return true
      end
    }
    return false
  end

  def initialize
    @updated = false	# only saves data if data updated
    @editing = nil	# when editor window is up, this is set.
    @verified = Time.now.to_i

    @pwd = get_salt || exit
    @pph = get_passphrase
    @passwords = PasswordsData.new(@pwd+@pph)
    # Password file exist?
    if @passwords.online? || @passwords.exist? # then
      # Yes, load passwords file.
      @passwords.load 
    else
      # No, check if there is a file....
      if has_datafile? # then
        # Yes, it's got a datafile. Ask for password again.
        while !@passwords.exist? do
          @pwd = get_salt('Try again!') || exit
          @passwords = PasswordsData.new(@pwd+@pph)
        end
        @passwords.load 
      else
      # Else, must be a new intall.
        pwd = @pwd
        @pwd = get_salt('Verify New Password') || exit
        while !(pwd == @pwd) do
          pwd = get_salt('Try again!') || exit
          @pwd = get_salt('Verify New Password') || exit
        end
      end
    end
    # Off to the races...
  end

  def verify_user
    now = Time.now.to_i
    if now - @verified > VERIFIED_EXPIRED then
      pwd0 = get_salt('Current Password')
      return false if !pwd0
      tries = 1
      while !(pwd0==@pwd) do
        tries += 1
        pwd0 = get_salt('CURRENT PASSWORD???')
        return false if !pwd0 || tries > 2
      end
    end
    @verified = now
    return true
  end

  def edit(combo_box, index)
    begin
      window = @editing
      window.signal_connect('delete_event') { @editing = nil }
      old_list = @passwords.accounts # dup not necessary

      vbox = Gtk::VBox.new
      window.add(vbox)

      pwdlength = Gtk::SpinButton.new(MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH, 1)
      pwdlength.value = DEFAULT_PASSWORD_LENGTH
      pwdlength.width_request = SPIN_BUTTON_LENGTH

      widget = {}
      EDITOR_LABELS.each {|s|
        hbox = Gtk::HBox.new
        label = Gtk::Label.new(TEXT[s]+':')
        label.modify_font(FONT)
        label.width_request = LABEL_WIDTH
        label.justify = Gtk::JUSTIFY_RIGHT
        label.wrap = true
        widget[s] = (s==:account)? Gtk::ComboBoxEntry.new : Gtk::Entry.new
        widget[s].width_request = ENTRY_WIDTH - ((s == :password)? SPIN_BUTTON_LENGTH+2*PAD: 0)
        widget[s].modify_font(FONT)
        hbox.pack_start(label, false, false, PAD)
        hbox.pack_end(pwdlength, false, false, PAD) if s == :password
        hbox.pack_end(widget[s], false, false, PAD)
        vbox.pack_start(hbox, false, false, PAD)
      }

      EDITOR_BUTTONS.each{|row|
        hbox = Gtk::HBox.new
        row.each {|s|
          widget[s] = Gtk::Button.new(TEXT[s])
          widget[s].child.modify_font(FONT)
          (s==:cancel || s==:save || s==:update)?
		hbox.pack_end(widget[s], false, false, PAD) :
		hbox.pack_start(widget[s], false, false, PAD)
        }
        vbox.pack_start(hbox, false, false, PAD)
      }

      # Account
      @passwords.accounts.each { |account|
        widget[:account].append_text( account )
      }
      widget[:account].active = index	if index
      account_changed = proc {
        account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
        if account.length > 0 then
          widget[:password].text	= ''
          if @passwords.include?(account) then
            widget[:url].text		= @passwords.url_of(account)
            widget[:note].text		= @passwords.note_of(account)
            widget[:username].text	= @passwords.username_of(account)
          else
            widget[:url].text		= ''
            widget[:note].text		= ''
            widget[:username].text	= ''
          end
        end
      }
      account_changed.call
      widget[:account].signal_connect('changed'){
        account_changed.call
      }

      # New Password
      widget[:password].visibility = false

      # Update
      widget[:update].signal_connect('clicked'){
        url = widget[:url].text.strip
        if url.length == 0 || url =~ URL_PATTERN then
          account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
          if account.length > 0 then
            @updated = true if !@updated
            if !@passwords.include?(account) then
              @passwords.add(account) 
              i = @passwords.accounts.index(account)
              widget[:account].insert_text(i,account)
            end
            @passwords.url_of(account, url)
            @passwords.note_of(account, widget[:note].text.strip)
            @passwords.username_of(account, widget[:username].text.strip)
            password = widget[:password].text.strip
            if password.length > 0 then
              @passwords.password_of(account, password) if !@passwords.verify?(account, password)
              widget[:password].text = ''
            end
          end
        else
          quick_message('Need url like http://www.site.com/page.html', window)
        end
      }
  
      # Random
      widget[:random].signal_connect('clicked'){
        suggestion = ''
        pwdlength.value.to_i.times do
          suggestion += (rand(94)+33).chr
        end
        widget[:password].text = suggestion
      }
      # Alpha-Numeric
      widget[:alphanum].signal_connect('clicked'){
        suggestion = ''
        while suggestion.length < pwdlength.value.to_i do
          chr = (rand(75)+48).chr
          suggestion += chr if chr =~/\w/
        end
        widget[:password].text = suggestion
      }
      # Numeric
      widget[:num].signal_connect('clicked'){
        suggestion = ''
        pwdlength.value.to_i.times do
          chr = (rand(10)+48).chr
          suggestion += chr
        end
        widget[:password].text = suggestion
      }
      # Letters
      widget[:alpha].signal_connect('clicked'){
        suggestion = ''
        while suggestion.length < pwdlength.value.to_i do
          chr = (rand(58)+65).chr
          suggestion += chr if chr =~/[A-Z]/i
        end
        widget[:password].text = suggestion
      }
      # Caps
      widget[:caps].signal_connect('clicked'){
        suggestion = ''
        pwdlength.value.to_i.times do
          chr = (rand(26)+65).chr
          suggestion += chr
        end
        widget[:password].text = suggestion
      }

      # Visibility
      widget[:visibility].signal_connect('clicked'){
        widget[:password].visibility = !widget[:password].visibility?
      }

      # Current
      widget[:current].signal_connect('clicked'){
        primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
        clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
        account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
        primary.text = clipboard.text = @passwords.password_of(account)
      }

      # Previous
      widget[:previous].signal_connect('clicked'){
        primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
        clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
        account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
        primary.text = clipboard.text = @passwords.previous_password_of(account)
      }

      # Change Password
      widget[:cpwd].signal_connect('clicked'){
        if verify_user then
          if pwd1 = get_salt('New Password') then
            if pwd2 = get_salt('Verify') then
              while !(pwd1==pwd2) do
                pwd1 = get_salt('Try again!')
                return if !pwd1
                pwd2 = get_salt('Verify')
                return if !pwd2
              end
              @pwd = pwd1
              @passwords.save(@pwd+@pph)
            end
          end
        else
          quit_windows
        end
      }

      # Change Passphrase
      widget[:cpph].signal_connect('clicked'){
        if verify_user then
          @pph = get_passphrase(true) # mv old passphrase? true
          @passwords.save(@pwd+@pph)
          quick_message('Passphrase Changed.', window)
        else
          quit_windows
        end
      }

      # Save
      widget[:save].signal_connect('clicked'){
        window.hide
        if @updated then
          if verify_user then
            @passwords.save
            @updated = false
            new_list = @passwords.accounts # dup not needed
            new_list.each {|account|
              if !old_list.include?(account) then
                i = new_list.index(account)
                old_list.insert(i,account)
                combo_box.insert_text(i,account)
              end
            }
            old_list.each {|account|
              if !new_list.include?(account) then
                i = old_list.index(account)
                old_list.delete_at(i)
                combo_box.remove_text(i)
              end
            }
            if i = new_list.index( widget[:account].active_text ) then
              combo_box.active = i
            end
          else
            quit_windows
          end
        end
        window.destroy
        @editing = nil
      }

      # Delete
      widget[:delete].signal_connect('clicked'){
        account = (widget[:account].active_text)? widget[:account].active_text.strip: nil
        if account then
          i = @passwords.accounts.index(account)
          if i then
            @passwords.delete(account)
            widget[:account].remove_text(i)
            widget[:account].active = (i > 0)? i - 1: 0
            @updated = true
            quick_message("#{account} deleted.", window)
          end
        end
      }

      # Cancel
      widget[:cancel].signal_connect('clicked'){
        window.hide
        if @updated then
          @passwords.load # revert
          @updated = false
        end
        window.destroy
        @editing = nil
      }

      window.show_all
    rescue Exception
      puts_bang!
    end
  end

  def run
    begin
      @window = window  = Gtk::Window.new
      window.signal_connect('delete_event') { quit_windows }

      vbox = Gtk::VBox.new
      window.add(vbox)

      combo_box =Gtk::ComboBox.new
      combo_box.modify_font(FONT)
      vbox.pack_start(combo_box, false, false, PAD)

      button = {}

      BUTTONS.each{ |row|
        hbox = Gtk::HBox.new
        row.each{|b|
          next if b == :edit && @passwords.online?
          button[b] = Gtk::Button.new(TEXT[b])
          button[b].modify_font(FONT)
          button[b].width_request = LABEL_WIDTH
          hbox.pack_start(button[b], false, false, PAD)
        }
        vbox.pack_start(hbox, false, false, PAD)
      }

      @passwords.accounts.each { |account|
        combo_box.append_text( account )
      }
      combo_box.active = 0

      if !@passwords.online? then
        button[:edit].child.modify_fg(Gtk::STATE_NORMAL, (@passwords.expired?(combo_box.active_text.strip))? RED: BLACK) if combo_box.active_text
        combo_box.signal_connect('changed'){
          txt = combo_box.active_text
          button[:edit].child.modify_fg(Gtk::STATE_NORMAL, (@passwords.expired?(txt.strip))? RED: BLACK) if txt
        }
      end

      button[:username].signal_connect('clicked'){
        primary	  = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
        clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
        account = (combo_box.active_text)? combo_box.active_text.strip: ''
        primary.text = clipboard.text = @passwords.username_of(account)
      }
      button[:current].signal_connect('clicked'){
        primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
        clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
        account = (combo_box.active_text)? combo_box.active_text.strip: ''
        primary.text = clipboard.text = @passwords.password_of(account)
      }
      button[:url].signal_connect('clicked'){
        account = (combo_box.active_text)? combo_box.active_text.strip: ''
        url = @passwords.url_of(account)
        if url.length > 0 && url =~ URL_PATTERN then
          system("#{BROWSER} '#{url}' > /dev/null 2>&1 &")
        end
      }
      button[:note].signal_connect('clicked'){
        account = (combo_box.active_text)? combo_box.active_text.strip: ''
        note = @passwords.note_of(account).strip
        note = '*** empty note ***' if note.length == 0
        quick_message(note,window)
      }

      if !@passwords.online? then
        button[:edit].signal_connect('clicked'){
          if !@editing then
            account = (combo_box.active_text)? combo_box.active_text.strip: ''
            i = @passwords.accounts.index(account)
            @editing = Gtk::Window.new
            edit(combo_box,i)
          end
        }
      end

      button[:quit].signal_connect('clicked'){ quit_windows }

      if !@passwords.online? && !@passwords.exist? then
        @editing = Gtk::Window.new
        edit(combo_box,0)
      end

      window.show_all
    rescue Exception
      puts_bang!
    end
  end

  def main_quit(icon)
      quit_windows
      icon.set_visible(false)
      icon = nil
      Gtk.main_quit
  end

  def status_icon
    icon = Gtk::StatusIcon.new
    icon.set_icon_name(Gtk::Stock::DIALOG_AUTHENTICATION)
    icon.tooltip = 'Password Manager'
    unlocked = true
    icon.signal_connect('activate') {
      if @window then
        quit_windows
      elsif unlocked then
        unlocked = false
        if verify_user then
          menu = Gtk::Menu.new
          @passwords.accounts.each {|account|
            menuitem = Gtk::MenuItem.new(account)
            menuitem.child.modify_fg(Gtk::STATE_NORMAL, RED) if @passwords.expired?(account)
            menu.append(menuitem)
            menuitem.signal_connect('activate'){|b|
              primary   = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
              clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
              primary.text = clipboard.text = @passwords.password_of(b.child.text.strip)
            }
          }
          menu.append( Gtk::SeparatorMenuItem.new )

          menuitem = Gtk::MenuItem.new('Quit')
          menuitem.signal_connect('activate'){ main_quit(icon) }
          menu.append(menuitem)

          Gtk::AboutDialog.set_url_hook{|about,link| system( "#{BROWSER} '#{link}' > /dev/null 2>&1 &" ) }
          menuitem = Gtk::MenuItem.new('About')
          menuitem.signal_connect('activate'){
            Gtk::AboutDialog.show(nil, ABOUT)
          }
          menu.append(menuitem)

          menuitem = Gtk::MenuItem.new('Run')
          menuitem.signal_connect('activate'){
            if !@window
              run if verify_user
            end
          }
          menu.append(menuitem)

          menu.show_all
          menu.popup(nil, nil, 0, 0)
          unlocked = true
        else
          main_quit(icon)
        end
      end
    }
    run if !@passwords.online? && !@passwords.exist?
    Gtk.main
  end
end
