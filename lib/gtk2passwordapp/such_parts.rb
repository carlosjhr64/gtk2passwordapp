Such::Parts.make('AbButtons', 'Box', :a_Button, :b_Button)
Such::Parts.make('AbcButtons', 'Box', :a_Button, :b_Button, :c_Button)
Such::Parts.make('PromptedEntryLabel', 'Box', :prompt_Label, :prompted_Entry, :prompted_Label)
Such::Parts.make('PromptedEntry', 'Box', :prompt_Label, :prompted_Entry)
Such::Parts.make('PromptedLabel', 'Box', :prompt_Label, :prompted_Label)
Such::Parts.make('PromptedCombo', 'Box', :prompt_Label, :prompted_ComboBoxText)

module Such
  class AbButtons
    def labels(a, b)
      self.a_Button.label = Gtk2PasswordApp::CONFIG[a]
      self.b_Button.label = Gtk2PasswordApp::CONFIG[b]
    end
  end
  class AbcButtons
    def labels(a, b, c)
      self.a_Button.label = Gtk2PasswordApp::CONFIG[a]
      self.b_Button.label = Gtk2PasswordApp::CONFIG[b]
      self.c_Button.label = Gtk2PasswordApp::CONFIG[c]
    end
  end
end
