require 'gtk2passwordapp/passwords_data'
require 'find'

class Gtk2PasswordMenu
  include Configuration

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

  def get_passphrase
    passphrase = ''

    pfile = USER_CONF_DIR+'/passphrase.txt'
    raise "Need passphrase file" if !File.exist?(pfile)
    File.open(pfile,'r'){|fh| passphrase = fh.read }

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
        raise "Need passwords data file"
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

  def main_quit(icon)
      icon.set_visible(false)
      icon = nil
      Gtk.main_quit
  end

  def status_icon
    icon = Gtk::StatusIcon.new
    icon.set_icon_name(Gtk::Stock::DIALOG_AUTHENTICATION)
    icon.tooltip = 'Password Menu'
    unlocked = true
    icon.signal_connect('activate') {
      if unlocked then
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

          menu.show_all
          menu.popup(nil, nil, 0, 0)
          unlocked = true
        else
          main_quit(icon)
        end
      end
    }
    Gtk.main
  end
end
