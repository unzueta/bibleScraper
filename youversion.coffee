nodeio = require 'node.io'
verses = {}
output = []

mongo = require 'mongoskin'
mongoDB = mongo.db 'localhost:27017/bible',{safe: true}

String.prototype.replaceAll  = (s1,s2) ->   
    this.replace(new RegExp(s1,"gm"),s2)

versions = 
    'CUNPSS' : 
        id : 48
        title : '新标点和合本'
        language: '简体中文'
    'CNVS' :
        id : 41
        title : '新译本'
        language: '简体中文'
    'CSBS' :
        id : 43
        title : '中文标准译本'
        language: '简体中文'
    'NIV' :
        id : 111
        title : 'New International Version'
        language: 'English'
    'KJV' :
        id : 1
        title : 'King James Version'
        language: 'English'

getText = (tag)->
    if tag.type=='text'
        tag.raw
    else
        verse = ''
        if tag.children
            for child in tag.children
                if not child.attribs or child.attribs.class!='label'
                    verse = verse + getText(child)
        verse

UnicodeToAscii = (content) ->
    code = content.match(/&#(\d+);/g) 
    result= content
    for char in code
        result = result.replaceAll(char,String.fromCharCode(char.replace(/[&#;]/g, '')))
    result

class Bible extends nodeio.JobClass
    run: (row)->   
        data = JSON.parse row
        @getHtml data.url, (err, $, scrapedData) =>
            throw err if err
            verses = []

            $('span.verse').each (span) ->
                verse = getText(span)

                v = verses[span.attribs['data-usfm']]
                if v
                    verse = v + ' ' + verse

                verses[span.attribs['data-usfm']] = verse

            for number,verse of verses
                verseNumber = parseInt(number.split('.')[2])

                mongoDB.collection('verse').insert
                    bookId : data.bookId
                    version: data.version
                    chapter: data.chapter
                    verse : verseNumber
                    content : UnicodeToAscii(verse).trim()
                , (err,result)->
                    if err
                        throw err
                    if result
                        console.log result
            
            mongoDB.collection('audio').insert
                bookId : data.bookId
                version: data.version
                chapter : data.chapter
                audioURL : 'http:'+ $('audio').attribs.src
            , (err,result)->
                if err
                    throw err

                if result
                    console.log result

            @emit output        

@class = Bible
@job = new Bible({timeout:10000, max: 20, retries: 5, auto_retry: true})

