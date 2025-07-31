const router = require('express').Router();
const Blog = require('../models/Blog');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

router.post('/', verifyToken, async (req, res) => {
    try {
        const blog = new Blog({ ...req.body, author: req.user.id });
        await blog.save();
        res.status(201).json(blog);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const blogs = await Blog.find().populate('author', 'username');
        res.status(200).json(blogs);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const blog = await Blog.findById(req.params.id).populate('author', 'username');
        res.status(200).json(blog);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.put('/:id', verifyToken, async (req, res) => {
    try {
        const blog = await Blog.findById(req.params.id);
        if (blog.author.toString() !== req.user.id)
            return res.status(403).json({ message: 'Unauthorized' });

        const updatedBlog = await Blog.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(200).json(updatedBlog);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.delete('/:id', verifyToken, async (req, res) => {
    try {
        const blog = await Blog.findById(req.params.id);
        if (blog.author.toString() !== req.user.id)
            return res.status(403).json({ message: 'Unauthorized' });

        await Blog.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Blog deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Wishlist routes
router.post('/wishlist/:blogId', verifyToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user.wishlist.includes(req.params.blogId)) {
            user.wishlist.push(req.params.blogId);
            await user.save();
        }
        res.status(200).json({ message: 'Added to wishlist' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.delete('/wishlist/:blogId', verifyToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        user.wishlist = user.wishlist.filter(id => id.toString() !== req.params.blogId);
        await user.save();
        res.status(200).json({ message: 'Removed from wishlist' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get('/wishlist/user', verifyToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('wishlist');
        res.status(200).json(user.wishlist);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;