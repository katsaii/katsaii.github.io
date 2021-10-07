vars = binding
page = read("contact/layout.html")
page = template(page, vars)
write("contact.html", page)
