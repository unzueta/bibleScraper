mongo = require 'mongoskin'
mongoDB = mongo.db 'localhost:27017/bible',{safe: true}

versions = 
    'CUNPSS' : 
        id : 48
        title : '新标点和合本'
    'CNVS' :
        id : 41
        title : '新译本'
    'CSBS' :
        id : 43
        title : '中文标准译本'
    'NIV' :
        id : 111
        title : 'New International Version'
    'KJV' :
        id : 1
        title : 'King James Version'

mongoDB.collection('book').find({}).toArray (err,result)->
    for versionName,version of versions
        for book in result
            for chapter in [1..book.chapters]
            	data = 
                	url : "https://www.youversion.com/bible/#{version.id}/#{book.eshort}.#{chapter}."+versionName.toLowerCase()
                	version: versionName
                	bookId: book.bookId
                	chapter: chapter
                console.log JSON.stringify(data)