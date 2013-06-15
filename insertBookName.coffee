mongo = require 'mongoskin'
mongoDB = mongo.db 'localhost:27017/bible',{safe: true}

mongoDB.collection('book').find({}).toArray (err,result)->
  books = {}
  for book in result
    console.log book
    mongoDB.collection('verse').update {bookId:book.bookId,version:'CUNPSS'}, {$set: {bookLongName: book.clong, bookShortName: book.cshort}}, { multi: true }, (err,result)->
      if result
    	  console.log result

