#These fns use a special dialect of MD that preserves new lines

#This array maps regexes to their replacement strings
#for the @MyNotes.HtmlToMd function
#ORDER MATTERS, do not change the order
htmltomd_replacements = [
  regex: /(\\|`|\*|_|{|}|\[|\]|\(|\)|#|\+|-|\.|!)/ig
  str: "\\$1"
,
  regex: /(<\/?b>)/ig
  str: "**"
,
  regex: /(<\/?i>)/ig
  str: "_"
,
  regex: /<a +href="(.*?)" *>(.*?)<\/a>/ig
  str: "[$2]($1)"
,
  regex: /<div><br\/?><\/div>/ig
  str: "\n\n"
,
  regex: /<br\/?>/ig
  str: "\n"
,
  regex: /^<div>(.*?)<\/div>$/ig
  str: "$1"
,
  regex: /^<div>(.*?)<\/div>/ig
  str: "$1\n"
,
  regex: /<div>(.*?)<\/div>/ig
  str: "\n$1"
]

#map for mynotes markdown to html
#Markdown libraries don't handle situations like <b>txt</b><b><i>txt</i></b><i>txt</i> correctly
#Also, markdown itself does not support arbitrary numbers of new lines
#ORDER MATTERS, do not change the order
mdtohtml_replacements = [
  regex: /\n\n/igm
  str: "<div><br/></div>"
,
  regex: /\n(.+?)($|<div>)/igm
  str: "<div>$1</div>$2"
,
  regex: /\n/igm
  str: "<br/>"
,
  regex: /([^\\]|^)\*\*(.*?)\*\*/ig
  str: "$1<b>$2</b>"
,
  regex: /([^\\]|^)\_(.*?)\_/ig
  str: "$1<i>$2</i>"
,
  regex: /\[(.*?)\]\((.*?)\)/ig
  str: '<a href="$2">$1</a>'
,
  regex: /\\(\\|`|\*|_|{|}|\[|\]|\(|\)|#|\+|-|\.|!)/ig
  str: "$1"
]

#private fn to do the replacement work
make_replacements = (str, replacements) ->
  ret_str = str
  for replacement in replacements
    do (replacement) ->
      ret_str = ret_str.replace replacement.regex, replacement.str
  return ret_str

#public functions
@MyNotes = {}

#fn to convert html to our dialect of markdown
@MyNotes.HtmlToMd = (html_string) ->
  if html_string?
    return make_replacements html_string, htmltomd_replacements
  else
    return ""

#Function to convert our dialect of markdown to html
@MyNotes.MdToHtml = (md_string) ->
  if md_string?
    return make_replacements md_string, mdtohtml_replacements
  else
    return ""
