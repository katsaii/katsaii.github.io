var href = window.location.href;
var a = document.createElement('a');
a.appendChild(document.createTextNode(`${href}`));
a.href = href;
var span = document.getElementById("url");
span.appendChild(document.createTextNode("("));
span.appendChild(a);
span.appendChild(document.createTextNode(") "));
