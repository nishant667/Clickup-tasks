import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Change to your backend URL

  // Auth
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {
        'token': data['token'],
        'user': User.fromJson(data['user']),
      };
    }
    return null;
  }

  static Future<bool> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    return res.statusCode == 201;
  }

  // Blogs
  static Future<List<dynamic>> fetchBlogs() async {
    final res = await http.get(Uri.parse('$baseUrl/blogs'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<bool> createBlog(String title, String content, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/blogs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    return res.statusCode == 201;
  }

  // Wishlist
  static Future<bool> addToWishlist(String blogId, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/blogs/wishlist/$blogId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return res.statusCode == 200;
  }

  static Future<bool> removeFromWishlist(String blogId, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/blogs/wishlist/$blogId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return res.statusCode == 200;
  }

  static Future<List<String>> getUserWishlist(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/blogs/wishlist/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data.map<String>((blog) => blog['_id']).toList();
    }
    return [];
  }
}