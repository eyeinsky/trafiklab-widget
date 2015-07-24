require 'json'
require 'pp'
require 'time'
require 'net/http'
require 'gtk3'

class TrafikLab

   BaseURL = 'https://api.trafiklab.se/samtrafiken'
   Defaults = 
      { :apiVersion => 2.1,
        :coordSys => 'RT90'
      }

   def initialize(apikey)
      @apikey = apikey
   end

   def mkURI(sub, meth, cmd)
      hash = TrafikLab::Defaults.merge({:key=>@apikey}).merge(cmd)
      params = URI.encode_www_form(hash)
      URI.parse "#{TrafikLab::BaseURL}/#{sub}/#{meth}.json?#{params}"
   end 

   def fromTo(from, to)
      t = Time.now
      cmd = { :fromId => from, :toId => to, :time => toHM(t.hour, t.min) }
      url = mkURI 'resrobot', 'Search', cmd
      res = Net::HTTP.get(url)
      JSON::parse(res)
   end

   def stopsQuery(loc, mins)
      cmd = { :locationId => loc, :timeSpan => mins }
      url = mkURI('resrobotstops', 'GetDepartures', cmd)
      #puts url
      res = Net::HTTP.get(url)
      JSON::parse(res)
   end

   def stops(loc, mins, mot=nil)
      json = stopsQuery(loc, mins)
      pp json
      deps = json['getdeparturesresult']['departuresegment']
      ret = []
      deps.each do |k,v|
         if mot == nil || k["direction"] == mot 
            ret.push k['departure']['datetime']
         end
      end
      ret
   end
end



# GTK window

class Widget < Gtk::Window

   def initialize(key, loc, mot, howMany)
      @tl = TrafikLab.new(key)
      @loc = loc
      @mot = mot
      @howMany = howMany
      super()
      init_ui
   end

   def toMarkup(timeText, now)
      time = Time.parse timeText
      mins = ((time - now) / 60).to_int
      "#{big mins} #{big time.strftime('(%H:%M)')}"
   end

   def getStops
      now = Time.now
      ret = @tl.stops(@loc, 120, @mot)[@howMany]
         . map{|x| toMarkup(x, now)}
         . join("\n")
      ret
   end

   def init_ui
      fixed = Gtk::Fixed.new
      add fixed

      @label = Gtk::Label.new nil
      update
      fixed.put @label, 0, 0
       
      signal_connect "destroy" do
         updater.kill; Gtk.main_quit
      end

      show_all
   end

   def update
      conts = getStops() # + "\nlast update: #{Time.now}"
      @label.set_markup(conts)
   end

end


# Helpers

def toHM(h,m)
   "#{'%02d'%h}:#{'%02d'%m}"
end

def big str
   "<span font='62'>#{str}</span>"
end




def getPossibleDirections(apikey, stop)
   #require 'pp'
   tl = TrafikLab.new(apikey)
   json = tl.stopsQuery(stop,120)
   #pp json
   json['getdeparturesresult']['departuresegment'].each do |k,v|
      dir = k['direction']
      type = k['segmentid']['mot']['#text']
      bussnr = k['segmentid']['carrier']['number']
      puts "'#{dir}' (bus nr #{bussnr})"
   end
end

# Run GTK

def runWidget(apikey, stop, mot=nil,howMany=1)
   Gtk.init
       window = Widget.new(apikey, stop, mot, 0..(howMany-1))
       window.decorated = false # remove top bar and window frame
       window.move(40,70)
       Thread.new do
         loop do 
            sleep 60           # first update happens init time
            window.update
            window.resize(1,1) # re-shrink, as a possible multi-row text made the window larger
         end
       end
   Gtk.main
end
