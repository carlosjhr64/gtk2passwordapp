class Gtk2PasswordApp
class Account

  PASSWORD    = 0
  PREVIOUS    = 1
  USERNAME    = 2
  URL         = 3
  NOTE        = 4
  UPDATED     = 5

  def initialize(name, data)
    unless data.has_key?(name)
      raise "Account name must be a non-empty String." unless name.class==String and name.length > 0
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

  def username
    @data[USERNAME]
  end

  def url
    @data[URL]
  end

  def note
    @data[NOTE]
  end

  def updated
    @data[UPDATED]
  end

  ### WRITTERS ###

  def password=(password)
    raise 'Password must be all graph.' unless password=~/^[[:graph:]]+$/
    if @data[PASSWORD] != password
      @data[UPDATED] = Time.now.to_i
      @data[PREVIOUS] = @data[PASSWORD]
      @data[PASSWORD] = password
    end
  end

  def note=(note)
    @data[NOTE]=note
  end

  def username=(username)
    raise 'Username must be all graph.' unless username=~/^[[:graph:]]*$/
    @data[USERNAME]=username
  end

  def url=(url)
    raise 'Must be like http://site' unless url=='' or url=~/^\w+:\/\/\S+$/
    @data[URL]=url
  end

end
end
