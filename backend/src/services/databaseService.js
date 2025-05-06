// MongoDB setup and utility functions (e.g., connecting DB, indexing collections).

const { MongoClient, ServerApiVersion } = require('mongodb');
require('dotenv').config();

async function connectToDatabase() {
    //returns a connection to database the MindFriendDB
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
  const client = new MongoClient(uri, {
    serverApi: ServerApiVersion.v1, // note removed some db things ( useNewUrlParser: true, useUnifiedTopology: true, )that were depreciated so npm could run.
  });

  try {
    await client.connect();
    console.log('Connected to MongoDB');
    return client.db(process.env.MONGODB_DB);
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    throw error;
  }
}

async function addDocument(document, collectionName) {
    //adds a document to a collection (i.e. table)
    //inputs [document [Dict]: dict of document to add, collecitonName [Str]: table name]
    const db = await connectToDatabase();
    const collection = db.collection(collectionName);
    const result = await collection.insertOne(document);
    console.log(`Document inserted with _id: ${result.insertedId}`);

}

async function getDocument(filter, collectionName) {
    //find documents that match a filter
    //inputs [filter [Dict]: dict of filter to match, collecitonName [Str]: table name]
    //outputs [document [List[Dict]]: dict of document that matches the filter]
    const db = await connectToDatabase();
    const collection = db.collection(collectionName);
    const document = await collection.find(filter);
    if (document) {
        console.log(`Document found: ${JSON.stringify(document)}`);
        return document;
    } else {
        console.log('No document matches the provided query.');
        return null;
    }
}

async function updateDocument(filter, update, collectionName) {
    //updates ONE document that matches a filter
    //inputs: [filter [Dict]: dict of filter to match, update [Dict]: dict of update to apply, collectionName [Str]: table name]
    //outputs: 1 if success, 0 otherwise
    const db = await connectToDatabase();
    const colleciton = db.collection(collectionName);

    const result = await collection.updateOne(filter, { $set: update });
    if (result.matchedCount > 0) {
        console.log(`Document updated: ${JSON.stringify(result)}`);
        return 1;
    } else {
        console.log('No document matches the provided query.');
        return 0;
    }
}

async function removeDocument(filter, collectionName) {
    //removes ONE document that matches a filter
    //inputs: [filter [Dict]: dict of filter to match, collectionName [Str]: table name]
    //outputs: 1 if success, 0 otherwise
    const db = await connectToDatabase();
    const collection = db.collection(collectionName);

    const result = await collection.deleteOne(filter);
    if (result.deletedCount > 0) {
        console.log(`Document deleted: ${JSON.stringify(result)}`);
        return 1;
    } else {
        console.log('No document matches the provided query.');
        return 0;
    }
}
