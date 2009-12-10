module Gtk2PasswordApp
   include Configuration

   PRIMARY = Gtk::Clipboard.get(Gdk::Selection::PRIMARY)
   CLIPBOARD = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)

   def self._rebuild_menu(menu,passwords)
     passwords.accounts.each {|account|
       item = menu.append_menu_item(account){
         PRIMARY.text   = passwords.password_of(account)
         CLIPBOARD.text = passwords.username_of(account)
       }
       item.child.modify_fg(Gtk::STATE_NORMAL, RED) if passwords.expired?(account)
     }
     menu.show_all
   end
   def self.rebuild_menu(menu,passwords)
     items = menu.children
     items.shift; items.shift # shift out Quit and Spacer
     while item = items.shift do
       menu.remove(item)
       item.destroy
     end
     Gtk2PasswordApp._rebuild_menu(menu,passwords)
   end
   def self.build_menu(menu,passwords)
     menu.append_menu_item('Quit'){ Gtk2App.quit }
     menu.append( Gtk::SeparatorMenuItem.new )
     Gtk2PasswordApp._rebuild_menu(menu,passwords)
   end

   def self.get_salt(title='Short Password')
     dialog = Gtk::Dialog.new(
         title,
         nil, nil,
         [ Gtk::Stock::QUIT,  0 ],
         [ Gtk::Stock::OK,  1 ])
 
     label = Gtk::Label.new(title)
     label.justify = Gtk::JUSTIFY_LEFT
     label.wrap = true
     label.modify_font(Configuration::FONT[:normal])
     dialog.vbox.add(label)
     entry = Gtk::Entry.new
     entry.visibility = false
     entry.modify_font(Configuration::FONT[:normal])
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
 
   DIALOGS = Gtk2App::Dialogs.new

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
 	#[ :delete, :cpwd, :cpph ],
 	[ :delete, :cpwd ],
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
 	:cpwd		=> 'Change Data File Password',
#	:cpph		=> 'Data File Passphrase',
 	:delete		=> 'Delete Account',
   }
 
   def self.edit(window, menu, passwords, index=nil)
     begin
       dialog_options = {:window=>window}
       updated = false	# only saves data if data updated

       vbox = Gtk::VBox.new
       window.add(vbox)
 
       pwdlength = Gtk::SpinButton.new(MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH, 1)
       pwdlength.value = DEFAULT_PASSWORD_LENGTH
       pwdlength.width_request = SPIN_BUTTON_LENGTH
       goto_url = Gtk::Button.new('Go')
       goto_url.width_request = GO_BUTTON_LENGTH
 
       widget = {}
       EDITOR_LABELS.each {|s|
         hbox = Gtk::HBox.new
         #label = Gtk::Label.new(TEXT[s]+':',hbox)
         label = Gtk2App::Label.new(TEXT[s]+':',hbox) # Gtk2App's Label
         #label.modify_font(FONT[:normal])
         label.width_request = LABEL_WIDTH
         label.justify = Gtk::JUSTIFY_RIGHT
         #label.wrap = true
         widget[s] = (s==:account)? Gtk::ComboBoxEntry.new : Gtk::Entry.new
         widget[s].width_request = ENTRY_WIDTH -
		((s == :password)? (SPIN_BUTTON_LENGTH+2*GUI[:padding]):
		((s == :url)? (GO_BUTTON_LENGTH+2*GUI[:padding]): 0))
         widget[s].modify_font(FONT[:normal])
         #hbox.pack_start(label, false, false, GUI[:padding])
         hbox.pack_end(pwdlength, false, false, GUI[:padding]) if s == :password
         hbox.pack_end(goto_url, false, false, GUI[:padding]) if s == :url
         hbox.pack_end(widget[s], false, false, GUI[:padding])
         vbox.pack_start(hbox, false, false, GUI[:padding])
       }

       # The go button opens the url in a browser
       goto_url.signal_connect('clicked'){
         system("#{APP[:browser]} #{widget[:url].text} > /dev/null 2> /dev/null &")
       }
 
       EDITOR_BUTTONS.each{|row|
         hbox = Gtk::HBox.new
         row.each {|s|
           widget[s] = Gtk::Button.new(TEXT[s])
           widget[s].child.modify_font(FONT[:normal])
           (s==:cancel || s==:save || s==:update || s==:cpwd)?
 		hbox.pack_end(widget[s], false, false, GUI[:padding]) :
 		hbox.pack_start(widget[s], false, false, GUI[:padding])
         }
         vbox.pack_start(hbox, false, false, GUI[:padding])
       }
 
       # Account
       passwords.accounts.each { |account|
         widget[:account].append_text( account )
       }
       widget[:account].active = index	if index
       account_changed = proc {
         account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
         if account.length > 0 then
           widget[:password].text	= ''
           if passwords.include?(account) then
             widget[:url].text		= passwords.url_of(account)
             widget[:note].text		= passwords.note_of(account)
             widget[:username].text	= passwords.username_of(account)
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
             updated = true if !updated
             if !passwords.include?(account) then
               passwords.add(account) 
               i = passwords.accounts.index(account)
               widget[:account].insert_text(i,account)
             end
             passwords.url_of(account, url)
             passwords.note_of(account, widget[:note].text.strip)
             passwords.username_of(account, widget[:username].text.strip)
             password = widget[:password].text.strip
             if password.length > 0 then
               passwords.password_of(account, password) if !passwords.verify?(account, password)
               widget[:password].text = ''
             end
           end
         else
           DIALOGS.quick_message('Need url like http://www.site.com/page.html', dialog_options)
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
         account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
         PRIMARY.text = passwords.password_of(account)
         CLIPBOARD.text = passwords.username_of(account)
       }
 
       # Previous
       widget[:previous].signal_connect('clicked'){
         account = (widget[:account].active_text)? widget[:account].active_text.strip: ''
         PRIMARY.text = passwords.previous_password_of(account)
         CLIPBOARD.text = passwords.username_of(account)
       }
 
       # Change Password
       widget[:cpwd].signal_connect('clicked'){
         if pwd1 = Gtk2PasswordApp.get_salt('New Password') then
           if pwd2 = Gtk2PasswordApp.get_salt('Verify') then
             while !(pwd1==pwd2) do
               pwd1 = Gtk2PasswordApp.get_salt('Try again!')
               return if !pwd1
               pwd2 = Gtk2PasswordApp.get_salt('Verify')
               return if !pwd2
             end
             #@pwd = pwd1
             passwords.save(pwd1)
           end
         end
       }
 
       # Change Passphrase
#      widget[:cpph].signal_connect('clicked'){
#        @pph = get_passphrase(true) # mv old passphrase? true
#        passwords.save(@pwd+@pph)
#      }
 
       # Save
       widget[:save].signal_connect('clicked'){
         if updated then
           passwords.save
           updated = false
           Gtk2PasswordApp.rebuild_menu(menu,passwords)
         end
         Gtk2App.close
       }
 
       # Delete
       widget[:delete].signal_connect('clicked'){
         account = (widget[:account].active_text)? widget[:account].active_text.strip: nil
         if account then
           i = passwords.accounts.index(account)
           if i then
             passwords.delete(account)
             widget[:account].remove_text(i)
             widget[:account].active = (i > 0)? i - 1: 0
             updated = true
             DIALOGS.quick_message("#{account} deleted.", dialog_options)
           end
         end
       }

       # Cancel
       widget[:cancel].signal_connect('clicked'){ Gtk2App.close }
       window.signal_connect('destroy'){
         if updated then
           passwords.load # revert
           updated = false
         end
       }
 
       window.show_all
     rescue Exception
       puts_bang!
     end
   end
end
