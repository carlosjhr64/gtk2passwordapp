module Gtk2passwordapp
class Account

  PASSWORD    = 0
  PREVIOUS    = 1
  NOTE        = 2
  USERNAME    = 3
  URL         = 4
  LAST_UPDATE = 5

  def initialize(name, data)
    unless data.has_key?(name)
      raise "Account name must be a String." unless name.class==String
      data[name] = [ '', '', '', '', '', 0 ]
    end
    @name, @data = name, data[name]
  end

  ### READERS ###

  def name
    @name
  end

  def password
    @data[PASSWORD]
  end

  def previous
    @data[PREVIOUS]
  end

  def note
    @data[NOTE]
  end

  def username
    @data[USERNAME]
  end

  def url
    @data[URL]
  end

  ### WRITTERS ###

  def password=(password)
    @data[LAST_UPDATE] = Time.now.to_i
    @data[PREVIOUS] = @data[PASSWORD]
    @data[PASSWORD] = password
  end

  def note=(note)
    @data[NOTE]=note
  end

  def username=(username)
    @data[USERNAME]=username
  end

  def url=(url)
    @data[URL]=url
  end

  ### HELPERS ###

  def verify?(password)
    @data[PASSWORD]==password
  end

  def expired?
    Time.now.to_i - @data[LAST_UPDATE] > CONFIG[:Expired]
  end

end
end
