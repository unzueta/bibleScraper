nodeio = require 'node.io'
verses = {}
output = []

characters =
	'&#160;' : ' '
	'&#8217;': '\''
	'&#8220;': '"'
	'&#8221;': '"'
	'&#8212;': '—'

getText = (tag)->
	if tag.type=='text'
		tag.raw
	else
		verse = ''
		if tag.children
			for child in tag.children
				if not child.attribs or child.attribs.class=='content'
					verse = verse + getText(child)
		verse

UnicodeToAscii = (content) ->
    code = content.match(/&#(\d+);/g) 
    result= ''
    for char in code
        result += String.fromCharCode(char.replace(/[&#;]/g, ''))
    result

class Reddit extends nodeio.JobClass
    input: false
    run: -> 
        @getHtml 'https://www.youversion.com/zh-CN/bible/43/rom.3.csbs', (err, $, data) =>
            @exit err if err

            $('span.verse').each (span) ->
            	verse = getText(span)
            	#for oldString,newString of characters
            	#	verse = verse.replace(new RegExp(oldString,"gm"),newString)

            	v = verses[span.attribs['data-usfm']]
            	if v
            		verse = v + ' ' + verse
            	
            	verses[span.attribs['data-usfm']] = verse

            for number,verse of verses
            	output.push UnicodeToAscii(verse)

            @emit output

@class = Reddit
@job = new Reddit({timeout:10})

