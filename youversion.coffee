nodeio = require 'node.io'
verses = {}
output = []

versions = 
    'Simplifed Chinese' :
        'CUNPSS' : 
            id : 48
            title : '新标点和合本'
        'CNVS' :
            id : 41
            title : '新译本'
        'CSBS' :
            id : 43
            title : '中文标准译本'
    'English' :
        'NIV' :
            id : 111
            title : 'New International Version'
        'KJV' :
            id : 1
            title : 'King James Version'


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

class Bible extends nodeio.JobClass
    input: false
    run: -> 
        @getHtml 'https://www.youversion.com/zh-CN/bible/43/rom.3.csbs', (err, $, data) =>
            @exit err if err

            $('span.verse').each (span) ->
            	verse = getText(span)

            	v = verses[span.attribs['data-usfm']]
            	if v
            		verse = v + ' ' + verse
            	
            	verses[span.attribs['data-usfm']] = verse

            for number,verse of verses
            	output.push UnicodeToAscii(verse)

            @emit output

@class = Bible
@job = new Bible({timeout:10})

