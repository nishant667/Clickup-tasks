const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors'); // Added CORS import
const authRoutes = require('./routes/auth');
const blogRoutes = require('./routes/blogs');
const { verifyToken } = require('./middleware/auth');

dotenv.config();
const app = express();
app.use(cors()); // Enable CORS for all origins
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/blogs', blogRoutes);

const PORT = process.env.PORT || 5000;
mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => app.listen(PORT, () => console.log(`Server running on ${PORT}`)))
    .catch((err) => console.error(err));