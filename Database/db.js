const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;


const uri = 'mongodb+srv://nishant:nishu@cluster0.wrjbqsk.mongodb.net/<Demo>?retryWrites=true&w=majority&appName=Cluster0';
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Middleware to parse JSON bodies
app.use(express.json());

async function connectToMongoDB() {
  try {
    if (!client.topology || !client.topology.isConnected()) {
      await client.connect();
      console.log('Successfully connected to MongoDB Atlas');
    }
    return client.db('<Demo>').collection('tasks'); // Use your actual DB name
  } catch (error) {
    console.error('Error connecting to MongoDB Atlas:', error);
    throw error;
  }
}

// POST /tasks endpoint
app.post('/tasks', async (req, res) => {
  const { title, description, status } = req.body;

  // Validate request body
  if (!title || !description || !status) {
    return res.status(400).json({
      error: 'Title, description, and status are required'
    });
  }

  // Validate status
  const validStatuses = ['pending', 'in-progress', 'completed'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      error: 'Invalid status. Must be one of: pending, in-progress, completed'
    });
  }

  try {
    const tasksCollection = await connectToMongoDB();
    
    // Create task document
    const task = {
      title,
      description,
      status,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Insert task into MongoDB
    const result = await tasksCollection.insertOne(task);
    res.status(201).json({
      message: 'Task created successfully',
      task: {
        _id: result.insertedId,
        ...task
      }
    });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// GET / endpoint
app.get('/', (req, res) => {
  res.send('Welcome to the Task API!');
});

// Test Task creation (you can remove this part later)
app.post('/test-task', (req, res) => {
  const testTask = {
    title: 'Test Task',
    description: 'This is a test',
    status: 'pending'
  };

  // Normally, you would save this to the database
  console.log('Test task data:', testTask);

  res.status(201).json({
    message: 'Test task created successfully',
    task: testTask
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

  