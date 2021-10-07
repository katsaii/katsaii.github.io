vars = binding
page = read("skills/layout.html")
page = template(page, vars)
write("skills.html", page)
