
module Gtk2PasswordApp
  vbox = 'Gtk2AppLib::Widgets::VBox'
  hbox = 'Gtk2AppLib::Widgets::HBox'
  classes = [
    ['Gui',	vbox,	[:Account_Component,:Url_Component,:Note_Component,:Username_Component,:Password_Component,:Buttons_Component]],
    ['Account',	hbox,	[:Account_Label,:Account_ComboBoxEntry]],
    ['Url',	hbox,	[:Url_Label,:Url_Entry,:Url_Button]],
    ['Note',	hbox,	[:Note_Label,:Note_Entry]],
    ['Username',hbox,	[:Username_Label,:Username_Entry]],
    ['Password',hbox,	[:Password_Label,:Password_Entry,:Password_CheckButton,:Password_SpinButton]],
    ['Buttons',	vbox,	[:Generators_Component,:Updates_Component,:Datafile_Component,:Clip_Component]],
    ['Generators',hbox,	[:Random_Button,:Alpha_Button,:Numeric_Button,:Letters_Button,:Caps_Button]],
    ['Updates',	hbox,	[:Cancel_Button,:Delete_Button,:Update_Button,:Save_Button]],
    ['Datafile',hbox,	[:Datafile_Button]],
    ['Clip',	hbox,	[:Current_Button,:Previous_Button]],
  ]
  classes.each{|clss,spr,keys| Gtk2AppLib::Component.define(clss,spr,keys)}
end
