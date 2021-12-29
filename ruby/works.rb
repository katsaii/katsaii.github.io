include Math

$links = [
    { :key => "github", :id => "GH", :alias => "GitHub" },
    { :key => "twitter", :id => "Tw", :alias => "Twitter" },
    { :key => "soundcloud", :id => "SC", :alias => "SoundCloud" },
    { :key => "bandcamp", :id => "Bc", :alias => "Bandcamp" },
    { :key => "newgrounds", :id => "Ng", :alias => "Newgrounds" },
    { :key => "deviantart", :id => "DA", :alias => "DeviantArt" },
    { :key => "tumblr", :id => "T", :alias => "Tumblr" },
    { :key => "steamcommunity", :id => "St", :alias => "Steam" }
]

##
# Converts this identifier into kebab-case.
def into_kebab(name)
    name.downcase.gsub(/\s+/, "-")
end

##
# Appends `-thumb` into the name of a file.
def thumb_path(path)
    head, tail = path.split(".", 2)
    "#{head}-thumb.#{tail}"
end

##
# Gets the abbreviated version of this url.
def abbreviate(url)
    $links.each do |x|
        if url.include?(x[:key])
            return x[:id]
        end
    end
    nil
end

def phantom_text
    "<span style=\"visibility : hidden;\">{ }</span>"
end

##
# Renders these artwork items inside of a CSS flexbox.
def render_art_items(items)
    out = "<div class=\"flex\">"
    items.each_with_index do |x, rad|
        name = x["name"]
        name = "Untitled" if name == nil
        image = x["src"]
        image = "#{into_kebab(name)}.png" if image == nil
        thumb = x["thumb"]
        thumb = thumb_path(image) if thumb == nil
        mirrors = x["mirrors"]
        mirrors = [] if mirrors == nil
        angle = 10 * Math::sin(rad + 1.5)
        out << "<div class=\"centre\">"
        out << "<div class=\"work\">"
        out << "<a href=\"/image/works/#{image}\" target=\"_blank\"><div style=\"--img : url('/image/works/#{thumb}'); --angle : #{angle}deg;\"></div></a>"
        out << "</div><div class=\"work-caption\">#{name}<br>"
        if mirrors.empty?
            out << phantom_text
        else
            out << "{"
            mirrors.each_with_index do |mirror, i|
                if i != 0
                    out << ","
                end
                abbr = abbreviate(mirror)
                abbr = i if abbr == nil
                out << " <a href=\"#{mirror}\" target=\"_blank\">#{abbr}</a>"
            end
            out << " }"
        end
        out << "</div></div>"
    end
    out + "\n</div>"
end

##
# Renders these music items inside of a CSS flexbox.
def render_music_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        name = x["name"]
        name = "Untitled" if name == nil
        audio = x["src"]
        audio = "#{into_kebab(name)}.ogg" if audio == nil
        mirrors = x["mirrors"]
        mirrors = [] if mirrors == nil
        out << "<div class=\"centre\">"
        out << "<audio class=\"work-audio\" controls controlsList=\"nodownload noplaybackrate\"><source src=\"/audio/works/#{audio}\" type=\"audio/ogg\"></audio>"
        out << "<div class=\"work-caption\">#{name}<br>"
        if mirrors.empty?
            out << phantom_text
        else
            out << "{"
            mirrors.each_with_index do |mirror, i|
                if i != 0
                    out << ","
                end
                abbr = abbreviate(mirror)
                abbr = i if abbr == nil
                out << " <a href=\"#{mirror}\" target=\"_blank\">#{abbr}</a>"
            end
            out << " }"
        end
        out << "</div></div>"
    end
    out + "\n</div>"
end

works_info = unmarshal_yaml(read("works/list.yaml"))
vars = binding
page = read("works/layout.html")
page = template(page, vars)
write("works.html", page)
