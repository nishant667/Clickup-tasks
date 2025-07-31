import 'package:flutter/material.dart';
import '../models/blog.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'create_blog_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final User user;
  const HomeScreen({Key? key, required this.token, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Blog>> blogsFuture;
  late Future<List<String>> wishlistFuture;
  Set<String> wishlist = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    blogsFuture = _fetchBlogs();
    wishlistFuture = _fetchWishlist();
  }

  Future<List<Blog>> _fetchBlogs() async {
    final data = await ApiService.fetchBlogs();
    return data.map<Blog>((json) => Blog.fromJson(json)).toList();
  }

  Future<List<String>> _fetchWishlist() async {
    final wishlistData = await ApiService.getUserWishlist(widget.token);
    setState(() {
      wishlist = wishlistData.toSet();
    });
    return wishlistData;
  }

  void _refresh() {
    setState(() {
      blogsFuture = _fetchBlogs();
      wishlistFuture = _fetchWishlist();
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _toggleWishlist(String blogId) async {
    final isWishlisted = wishlist.contains(blogId);
    bool success;
    
    if (isWishlisted) {
      success = await ApiService.removeFromWishlist(blogId, widget.token);
    } else {
      success = await ApiService.addToWishlist(blogId, widget.token);
    }

    if (success) {
      setState(() {
        if (isWishlisted) {
          wishlist.remove(blogId);
        } else {
          wishlist.add(blogId);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isWishlisted ? 'Removed from wishlist' : 'Added to wishlist'),
          backgroundColor: isWishlisted ? Colors.orange.shade600 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Blog App'),
            Text(
              'Welcome, ${widget.user.username}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              setState(() { _selectedTab = 1; });
            },
            tooltip: 'Wishlist',
            color: _selectedTab == 1 ? Colors.red : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Blog>>(
        future: blogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading blogs...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _selectedTab == 0 ? 'No blogs yet.' : 'No wishlisted blogs.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_selectedTab == 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to create a blog!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          
          final blogs = snapshot.data!;
          final showBlogs = _selectedTab == 0
              ? blogs
              : blogs.where((b) => wishlist.contains(b.id)).toList();
              
          if (showBlogs.isEmpty && _selectedTab == 1) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No wishlisted blogs.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding blogs to your wishlist!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: showBlogs.length,
            itemBuilder: (context, i) {
              final blog = showBlogs[i];
              final isWishlisted = wishlist.contains(blog.id);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Show blog details dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        blog.title,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                                        color: isWishlisted ? Colors.red : null,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _toggleWishlist(blog.id);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(blog.content),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      blog.authorName != null ? 'by ${blog.authorName}' : '',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  blog.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: IconButton(
                                  key: ValueKey(isWishlisted),
                                  icon: Icon(
                                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: isWishlisted ? Colors.red : null,
                                  ),
                                  onPressed: () => _toggleWishlist(blog.id),
                                  tooltip: isWishlisted ? 'Remove from wishlist' : 'Add to wishlist',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            blog.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                blog.authorName != null ? 'by ${blog.authorName}' : '',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Read more',
                                  style: TextStyle(
                                    color: const Color(0xFF6366F1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateBlogScreen(token: widget.token),
                  ),
                );
                if (created == true) _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Blog'),
              tooltip: 'Create Blog',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }
}
