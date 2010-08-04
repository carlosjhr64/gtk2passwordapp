require 'gtk2passwordapp/passwords'
module Gtk2PasswordApp
   include Configuration
   PRIMARY	= Gtk::Clipboard.get((SWITCH_CLIPBOARDS)? Gdk::Selection::CLIPBOARD: Gdk::Selection::PRIMARY)
   CLIPBOARD	= Gtk::Clipboard.get((SWITCH_CLIPBOARDS)? Gdk::Selection::PRIMARY: Gdk::Selection::CLIPBOARD)

   @@index = nil
   def self.build_menu(passwords)
     passwords.accounts.each {|account|
       item = PROGRAM.dock_menu.append_menu_item(account){
         @@index = passwords.accounts.index(account)
         PRIMARY.text   = passwords.password_of(account)
         CLIPBOARD.text = passwords.username_of(account)
       }
       item.child.modify_fg(Gtk::STATE_NORMAL, COLOR[:red]) if passwords.expired?(account)
     }
     PROGRAM.dock_menu.show_all
   end
   def self.rebuild_menu(passwords)
     items = PROGRAM.dock_menu.children
     3.times{ items.shift } # shift out Quit, Run, and Spacer
     while item = items.shift do
       PROGRAM.dock_menu.remove(item)
       item.destroy
     end
     Gtk2PasswordApp.build_menu(passwords)
   end

   def self.get_salt(prompt,title=prompt)
     Gtk2AppLib::DIALOGS.entry(prompt,{:title=>title,:visibility=>false})
   end
 
   EDITOR_LABELS = [
 	:account,
  	:url,
  	:note,
  	:username,
  	:password,
 	]
 
 
   EDITOR_BUTTONS = [
 	[ :random, :alphanum, :num, :alpha, :caps, ],
 	[ :cancel, :delete, :update, :save, ],
 	[ :cpwd ],
 	[ :current, :previous, ],
 	]
 
   TEXT = {
 	# Labels
 	:account	=> 'Account',
 	:note		=> 'Note',
 	:password	=> 'New',
 	# Buttons
 	:username	=> 'Username',
 	:current	=> 'Clip Current Password',
 	:url		=> 'Url',
 	:note		=> 'Note',
 	:edit		=> 'Edit',
 	:update		=> 'Update Account',
 	:alphanum	=> 'Alpha-Numeric',
 	:num		=> 'Numeric',
 	:alpha		=> 'Letters',
 	:caps		=> 'All-Caps',
 	:random		=> 'Random',
 	:previous	=> 'Clip Previous Password',
 	:quit		=> 'Quit',
 	:cancel		=> 'Cancel All Changes',
 	:save		=> 'Save To Disk',
 	:cpwd		=> 'Change Data File Password',
 	:delete		=> 'Delete Account',
   }
 
   def self.edit(window, passwords)
       dialog_options = {:window=>window}
       updated = false	# only saves data if data updated

       vbox = Gtk2AppLib::VBox.new(window)
 
       goto_url = pwdlength = visibility = nil
 
       widget = {}
       EDITOR_LABELS.each {|s|
         hbox = Gtk2AppLib::HBox.new(vbox)
         label = Gtk2AppLib::Label.new(TEXT[s]+':',hbox,{:label_width=>LABEL_WIDTH})
         dx =  ((s == :password)? (SPIN_BUTTON_LENGTH+2*PADDING+30): ((s == :url)? (GO_BUTTON_LENGTH+2*PADDING): 0))
         width = ENTRY_WIDTH  - dx
         widget[s] = (s==:account)?
		Gtk2AppLib::ComboBoxEntry.new(passwords.accounts,hbox,{:comboboxentry_width=>width}) :
		Gtk2AppLib::Entry.new('',hbox,{:entry_width=>width})

         if s == :password then
           visibility = Gtk2AppLib::CheckButton.new(hbox,{:active=>true})
           pwdlength = Gtk2AppLib::SpinButton.new(hbox)
           pwdlength.value = DEFAULT_PASSWORD_LENGTH
         elsif s == :url then
           goto_url = Gtk2AppLib::Button.new('Go',hbox,{:button_width=>GO_BUTTON_LENGTH}){
             # The go button opens the url in a browser
             system("#{APP[:browser]} #{widget[:url].text} > /dev/null 2> /dev/null &")
           }
         end
       }

       EDITOR_BUTTONS.each{|row|
         hbox = Gtk2AppLib::HBox.new(vbox)
         row.each {|s| widget[s] = Gtk2AppLib::Button.new(TEXT[s],hbox) }
       }
 
       widget[:account].active = @@index	if @@index
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
           @@index = widget[:account].active
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
               @@index = i = passwords.accounts.index(account)
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
           Gtk2AppLib::DIALOGS.quick_message('Need url like http://www.site.com/page.html', dialog_options)
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
       visibility.signal_connect('clicked'){
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
             Gtk2AppLib.passwords_updated
           end
         end
       }
 
       # Save
       widget[:save].signal_connect('clicked'){
         if updated then
           passwords.save
           Gtk2AppLib.passwords_updated
           updated = false
           Gtk2PasswordApp.rebuild_menu(passwords)
         end
         PROGRAM.close
       }
 
       # Delete
       widget[:delete].signal_connect('clicked'){
         account = (widget[:account].active_text)? widget[:account].active_text.strip: nil
         if account then
           i = passwords.accounts.index(account)
           if i then
             passwords.delete(account)
             widget[:account].remove_text(i)
             @@index = (widget[:account].active = (i > 0)? i - 1: 0)
             updated = true
             Gtk2AppLib::DIALOGS.quick_message("#{account} deleted.", dialog_options)
           end
         end
       }

       # Cancel
       widget[:cancel].signal_connect('clicked'){ PROGRAM.close }
       window.signal_connect('destroy'){
         if updated then
           passwords.load # revert
           updated = false
         end
       }
 
       window.show_all
   end
end
