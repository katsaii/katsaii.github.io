
##
# Renders these items inside of a CSS flexbox.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        image = x["image"]
        thumb = x["thumb"]
        thumb = image if thumb == nil
        name = x["name"]
        name = "Img" if name == nil
        mirrors = x["mirrors"]
        mirrors = [] if mirrors == nil
        mirrors << image
        angle = x["angle"]
        angle = 0 if angle == nil
        out << "<div class=\"centre\">"
        out << "<div class=\"work\">"
        out << "<a href=\"#{image}\"><div style=\"--img : url('#{thumb}'); --angle : #{angle}deg;\"></div></a>"
        out << "</div><div class=\"img-caption\">data #{name} ="
        mirrors.each_with_index do |mirror, i|
            if i != 0
                out << " |"
            end
            out << " <a href=\"#{mirror}\">#{('A'.ord + i).chr}</a>"
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
