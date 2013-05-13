sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("CUVS.db")

mongo = require 'mongoskin'
mongoDB = mongo.db 'localhost:27017/bible',{safe: true}
#mongoDB.createCollection 'book'
db.serialize ->
  
  db.each "SELECT * from book", (err, row) ->
    console.log JSON.stringify(row)
    mongoDB.collection('book').insert
      bookId : row.id
      clong: row.clong
      cshort: row.cshort
      elong: row.elong
      eshort: row.eshort
      pylong: row.pylong
      pyshort: row.pyshort
      allNames: row.clong+':'+row.cshort+':'+row.elong+':'+row.eshort+':'+row.pylong+':'+row.pyshort
     , (err,result)->
     	if result
     	  console.log result

  db.each "SELECT * FROM verse group by bookid", (err,row)->
  	console.log JSON.stringify(row)
  	mongoDB.collection('book').update {bookId:row.bookid}, {$set: {chapters: row.chapterid}},(err,result)->
  	  if result
  	  	console.log result
db.close()
