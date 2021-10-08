include Math

##
# Gets the abbreviated version of this url.
def abbreviate(url)
    if url.include?("github") then "GH"
    elsif url.include?("twitter") then "Tw"
    elsif url.include?("soundcloud") then "SC"
    elsif url.include?("newgrounds") then "Ng"
    elsif url.include?("deviantart") then "DA"
    elsif url.include?("tumblr") then "T"
    else nil
    end
end

##
# Renders these items inside of a CSS flexbox.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each_with_index do |x, rad|
        image = x["image"]
        thumb = x["thumb"]
        thumb = image if thumb == nil
        name = x["name"]
        name = "Img" if name == nil
        mirrors = x["mirrors"]
        mirrors = [] if mirrors == nil
        angle = 10 * Math::sin(rad + 1.5)
        out << "<div class=\"centre\">"
        out << "<div class=\"work\">"
        out << "<a href=\"#{image}\"><div style=\"--img : url('#{thumb}'); --angle : #{angle}deg;\"></div></a>"
        out << "</div><div class=\"img-caption\">#{name}<br>{"
        mirrors.each_with_index do |mirror, i|
            if i != 0
                out << ","
            end
            abbr = abbreviate(mirror)
            abbr = i if abbr == nil
            out << " <a href=\"#{mirror}\" target=\"_blank\">#{abbr}</a>"
        end
        out << " }</div></div>"
    end
    out + "\n</div>"
end

works_info = unmarshal_yaml(read("works/list.yaml"))
vars = binding
page = read("works/layout.html")
page = template(page, vars)
write("works.html", page)
