
##
# Renders these items inside of a CSS flexbox.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        image = x["image"]
        mirrors = x["mirrors"]
        mirrors = [] if mirrors == nil
        mirrors << image
        angle = x["angle"]
        angle = 0 if angle == nil
        out << "<div class=\"centre\">"
        out << "<div class=\"work\">"
        out << "<a href=\"#{image}\"><div style=\"--img : url('#{image}'); --angle : #{angle}deg;\"></div></a>"
        out << "</div><div class=\"img-caption\">src ="
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
